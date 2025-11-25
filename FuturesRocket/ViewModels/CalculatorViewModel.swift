import Foundation
import Combine
import UIKit
import SwiftUI

/// Drives the Home tab calculator UI and derives position sizing outputs.
final class CalculatorViewModel: ObservableObject {
    @Published var symbol: String = "BTCUSDT"
    @Published var direction: TradeDirection = .long
    @Published var entryPrice: Double = 27000
    @Published var stopLoss: Double = 26000
    @Published var dcaEntries: [DCAEntry] = []
    @Published var takeProfits: [TakeProfitLevel] = []

    @Published private(set) var totalUnits: Double = 0
    @Published private(set) var averageEntry: Double = 0
    @Published private(set) var trimmedUnits: [UUID: Double] = [:]
    @Published private(set) var riskAmount: Double = 0

    private var cancellables = Set<AnyCancellable>()
    private let calculator = TradeCalculator()
    private let haptics = UIImpactFeedbackGenerator(style: .light)

    init(appState: AppState) {
        let publisher = Publishers.CombineLatest4(
            appState.$settings,
            $entryPrice,
            $stopLoss,
            $dcaEntries
        )
        .combineLatest($takeProfits, $direction)
        .debounce(for: .milliseconds(150), scheduler: DispatchQueue.main)

        publisher
            .sink { [weak self] settings, takeProfits, direction in
                guard let self else { return }
                self.recompute(using: settings, direction: direction)
                self.trimmedUnits = self.calculator.trimPlan(totalUnits: self.totalUnits, takeProfits: takeProfits)
            }
            .store(in: &cancellables)
    }

    func addDCA() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7, blendDuration: 0.3)) {
            dcaEntries.append(DCAEntry(price: entryPrice, riskSharePercent: 10))
            haptics.impactOccurred(intensity: 0.7)
        }
    }

    func removeDCA(_ entry: DCAEntry) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7, blendDuration: 0.3)) {
            dcaEntries.removeAll { $0.id == entry.id }
            haptics.impactOccurred(intensity: 0.5)
        }
    }

    func addTakeProfit() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7, blendDuration: 0.3)) {
            takeProfits.append(TakeProfitLevel(tpPrice: entryPrice * 1.02, trimPercentOfPosition: 25))
            haptics.impactOccurred(intensity: 0.7)
        }
    }

    func removeTakeProfit(_ level: TakeProfitLevel) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7, blendDuration: 0.3)) {
            takeProfits.removeAll { $0.id == level.id }
            haptics.impactOccurred(intensity: 0.5)
        }
    }

    func validationMessage(settings: AppSettings) -> String? {
        let dcaTotal = dcaEntries.reduce(0) { $0 + $1.riskSharePercent }
        if dcaTotal > 100 { return "Risk split exceeds 100%" }
        let tpTotal = takeProfits.reduce(0) { $0 + $1.trimPercentOfPosition }
        if tpTotal > 100 { return "TP trim exceeds 100%" }
        if entryPrice == stopLoss { return "Entry and SL cannot match" }
        if settings.currentCapital <= 0 { return "Current capital must be positive" }
        return nil
    }

    private func recompute(using settings: AppSettings, direction: TradeDirection) {
        let result = calculator.calculatePosition(
            accountCapital: settings.currentCapital,
            riskPercent: settings.riskPercent,
            direction: direction,
            entryPrice: entryPrice,
            stopLoss: stopLoss,
            dcaEntries: dcaEntries
        )
        totalUnits = result.totalUnits
        averageEntry = result.averageEntry
        riskAmount = result.totalRiskAmount
    }

    func buildSavedTrade(outcome: TradeOutcome, settings: AppSettings) -> SavedTrade {
        let pnl = calculator.realizedPnL(
            direction: direction,
            averageEntry: averageEntry,
            stopLoss: stopLoss,
            takeProfits: takeProfits,
            totalUnits: totalUnits,
            outcome: outcome
        )
        return SavedTrade(
            symbol: symbol,
            direction: direction,
            dateOpened: Date(),
            dateClosed: Date(),
            entryPrice: averageEntry,
            stopLoss: stopLoss,
            dcaEntries: dcaEntries,
            takeProfits: takeProfits,
            outcome: outcome,
            realizedPnL: pnl,
            note: nil
        )
    }
}
