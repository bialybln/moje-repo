import Foundation

/// Handles lightweight persistence via UserDefaults using Codable wrappers.
final class PersistenceService {
    static let shared = PersistenceService()
    private let settingsKey = "futuresrocket.settings"
    private let tradesKey = "futuresrocket.trades"
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    private init() {}

    func loadSettings() -> AppSettings {
        guard let data = UserDefaults.standard.data(forKey: settingsKey),
              let settings = try? decoder.decode(AppSettings.self, from: data) else {
            return AppSettings()
        }
        return settings
    }

    func save(settings: AppSettings) {
        if let data = try? encoder.encode(settings) {
            UserDefaults.standard.set(data, forKey: settingsKey)
        }
    }

    func loadTrades() -> [SavedTrade] {
        guard let data = UserDefaults.standard.data(forKey: tradesKey),
              let trades = try? decoder.decode([SavedTrade].self, from: data) else {
            return []
        }
        return trades
    }

    func save(trades: [SavedTrade]) {
        if let data = try? encoder.encode(trades) {
            UserDefaults.standard.set(data, forKey: tradesKey)
        }
    }
}
