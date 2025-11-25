import Foundation
import Combine

/// Global source of truth for settings and trade history shared across tabs.
final class AppState: ObservableObject {
    @Published var settings: AppSettings
    @Published var trades: [SavedTrade]

    private let persistence: PersistenceService

    init(persistence: PersistenceService = .shared) {
        self.persistence = persistence
        self.settings = persistence.loadSettings()
        self.trades = persistence.loadTrades()
    }

    func update(settings: AppSettings) {
        self.settings = settings
        persistence.save(settings: settings)
    }

    func add(trade: SavedTrade) {
        trades.insert(trade, at: 0)
        persistence.save(trades: trades)
    }

    func update(trade: SavedTrade) {
        if let index = trades.firstIndex(where: { $0.id == trade.id }) {
            trades[index] = trade
            persistence.save(trades: trades)
        }
    }
}
