import Foundation

/// User-configurable preferences driving calculator logic.
public struct AppSettings: Codable, Equatable {
    public var initialCapital: Double
    public var currentCapital: Double
    public var riskPercent: Double
    public var targetCapital: Double

    public init(initialCapital: Double = 10000, currentCapital: Double = 10000, riskPercent: Double = 2, targetCapital: Double = 20000) {
        self.initialCapital = initialCapital
        self.currentCapital = currentCapital
        self.riskPercent = riskPercent
        self.targetCapital = targetCapital
    }
}
