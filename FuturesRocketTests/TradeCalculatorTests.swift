import XCTest
@testable import FuturesRocket

final class TradeCalculatorTests: XCTestCase {
    func testPositionWithoutDCA() {
        let calc = TradeCalculator()
        let result = calc.calculatePosition(
            accountCapital: 10_000,
            riskPercent: 2,
            direction: .long,
            entryPrice: 100,
            stopLoss: 95,
            dcaEntries: []
        )
        XCTAssertEqual(result.totalUnits, 40, accuracy: 0.001)
        XCTAssertEqual(result.averageEntry, 100, accuracy: 0.001)
    }

    func testPositionWithDCA() {
        let calc = TradeCalculator()
        let dca = [DCAEntry(price: 90, riskSharePercent: 50)]
        let result = calc.calculatePosition(
            accountCapital: 20_000,
            riskPercent: 1,
            direction: .long,
            entryPrice: 100,
            stopLoss: 80,
            dcaEntries: dca
        )
        XCTAssertGreaterThan(result.totalUnits, 0)
        XCTAssertLessThan(result.averageEntry, 100)
    }

    func testTakeProfitPnl() {
        let calc = TradeCalculator()
        let tps = [TakeProfitLevel(tpPrice: 120, trimPercentOfPosition: 50), TakeProfitLevel(tpPrice: 140, trimPercentOfPosition: 50)]
        let pnl = calc.realizedPnL(
            direction: .long,
            averageEntry: 100,
            stopLoss: 90,
            takeProfits: tps,
            totalUnits: 10,
            outcome: .takeProfit(reachedLevels: 2)
        )
        XCTAssertEqual(pnl, 300)
    }
}
