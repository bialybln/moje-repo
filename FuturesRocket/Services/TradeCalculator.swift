import Foundation

/// Encapsulates the business rules for position sizing and PnL calculations.
struct TradeCalculator {
    struct PositionResult {
        let totalUnits: Double
        let averageEntry: Double
        let totalRiskAmount: Double
    }

    /// Computes the aggregate position size from a base entry plus optional DCA legs.
    func calculatePosition(
        accountCapital: Double,
        riskPercent: Double,
        direction: TradeDirection,
        entryPrice: Double,
        stopLoss: Double,
        dcaEntries: [DCAEntry]
    ) -> PositionResult {
        let riskAmount = accountCapital * riskPercent / 100
        let perUnitRisk = abs(entryPrice - stopLoss)
        let baseRiskShare = 100 - dcaEntries.reduce(0) { $0 + $1.riskSharePercent }
        let normalizedDCA = dcaEntries + [DCAEntry(price: entryPrice, riskSharePercent: max(0, baseRiskShare))]

        let unitsPerEntry = normalizedDCA.map { entry -> Double in
            let allocated = riskAmount * entry.riskSharePercent / 100
            return allocated / perUnitRisk
        }
        let totalUnits = unitsPerEntry.reduce(0, +)
        let weightedPriceSum = zip(normalizedDCA, unitsPerEntry).reduce(0.0) { partial, element in
            partial + element.0.price * element.1
        }
        let averageEntry = totalUnits == 0 ? entryPrice : weightedPriceSum / totalUnits
        return PositionResult(totalUnits: totalUnits, averageEntry: averageEntry, totalRiskAmount: riskAmount)
    }

    /// Computes how many units are trimmed per take-profit level.
    func trimPlan(totalUnits: Double, takeProfits: [TakeProfitLevel]) -> [UUID: Double] {
        takeProfits.reduce(into: [:]) { result, level in
            result[level.id] = totalUnits * level.trimPercentOfPosition / 100
        }
    }

    /// Calculates realized PnL given the trade outcome and laddered TP distribution.
    func realizedPnL(
        direction: TradeDirection,
        averageEntry: Double,
        stopLoss: Double,
        takeProfits: [TakeProfitLevel],
        totalUnits: Double,
        outcome: TradeOutcome
    ) -> Double {
        let sign = direction.sign
        switch outcome {
        case .breakEven:
            return 0
        case .stopLoss:
            let exitPrice = stopLoss
            return totalUnits * (exitPrice - averageEntry) * sign
        case .takeProfit(let reachedLevels):
            let capped = max(1, min(reachedLevels, takeProfits.count))
            let trimmed = takeProfits.prefix(capped - 1)
            let last = takeProfits.prefix(capped).last!
            let trimmedPercent = trimmed.reduce(0) { $0 + $1.trimPercentOfPosition }
            let remainingPercent = max(0, 100 - trimmedPercent)
            var total = 0.0
            for tp in trimmed {
                let units = totalUnits * tp.trimPercentOfPosition / 100
                total += units * (tp.tpPrice - averageEntry) * sign
            }
            let remainingUnits = totalUnits * remainingPercent / 100
            total += remainingUnits * (last.tpPrice - averageEntry) * sign
            return total
        }
    }
}
