import Foundation

/// Long or short direction for a futures position.
public enum TradeDirection: String, Codable, CaseIterable, Identifiable {
    case long
    case short

    public var id: String { rawValue }
    public var displayName: String { rawValue.capitalized }
    public var sign: Double { self == .long ? 1 : -1 }
}

/// Represents a single DCA leg with its share of risk allocation.
public struct DCAEntry: Codable, Identifiable, Equatable {
    public let id: UUID
    public var price: Double
    public var riskSharePercent: Double

    public init(id: UUID = UUID(), price: Double, riskSharePercent: Double) {
        self.id = id
        self.price = price
        self.riskSharePercent = riskSharePercent
    }
}

/// Represents a take-profit level and how much of the position to trim there.
public struct TakeProfitLevel: Codable, Identifiable, Equatable {
    public let id: UUID
    public var tpPrice: Double
    public var trimPercentOfPosition: Double

    public init(id: UUID = UUID(), tpPrice: Double, trimPercentOfPosition: Double) {
        self.id = id
        self.tpPrice = tpPrice
        self.trimPercentOfPosition = trimPercentOfPosition
    }
}

/// Outcome of a saved trade.
public enum TradeOutcome: Codable, Equatable {
    case stopLoss
    case breakEven
    case takeProfit(reachedLevels: Int)
}

/// Persisted representation of a completed trade.
public struct SavedTrade: Codable, Identifiable, Equatable {
    public let id: UUID
    public var symbol: String
    public var direction: TradeDirection
    public var dateOpened: Date
    public var dateClosed: Date
    public var entryPrice: Double
    public var stopLoss: Double
    public var dcaEntries: [DCAEntry]
    public var takeProfits: [TakeProfitLevel]
    public var outcome: TradeOutcome
    public var realizedPnL: Double
    public var note: String?

    public init(
        id: UUID = UUID(),
        symbol: String,
        direction: TradeDirection,
        dateOpened: Date,
        dateClosed: Date,
        entryPrice: Double,
        stopLoss: Double,
        dcaEntries: [DCAEntry],
        takeProfits: [TakeProfitLevel],
        outcome: TradeOutcome,
        realizedPnL: Double,
        note: String? = nil
    ) {
        self.id = id
        self.symbol = symbol
        self.direction = direction
        self.dateOpened = dateOpened
        self.dateClosed = dateClosed
        self.entryPrice = entryPrice
        self.stopLoss = stopLoss
        self.dcaEntries = dcaEntries
        self.takeProfits = takeProfits
        self.outcome = outcome
        self.realizedPnL = realizedPnL
        self.note = note
    }
}
