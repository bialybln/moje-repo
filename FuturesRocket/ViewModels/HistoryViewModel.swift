import Foundation
import Combine
import SwiftUI

/// Exposes history list with animated capital progress.
final class HistoryViewModel: ObservableObject {
    @Published private(set) var trades: [SavedTrade] = []
    @Published private(set) var capitalProgress: Double = 0
    @Published private(set) var currentCapital: Double = 0
    @Published private(set) var targetCapital: Double = 0

    private var cancellables = Set<AnyCancellable>()

    init(appState: AppState) {
        appState.$trades
            .receive(on: DispatchQueue.main)
            .assign(to: &self.$trades)

        appState.$settings
            .receive(on: DispatchQueue.main)
            .sink { [weak self] settings in
                guard let self else { return }
                self.currentCapital = settings.currentCapital
                self.targetCapital = settings.targetCapital
                let ratio = settings.targetCapital == 0 ? 0 : settings.currentCapital / settings.targetCapital
                self.capitalProgress = min(max(ratio, 0), 1)
            }
            .store(in: &cancellables)
    }

    func subtitle(for trade: SavedTrade) -> String {
        switch trade.outcome {
        case .stopLoss: return "SL"
        case .breakEven: return "BE"
        case .takeProfit(let level): return "TP" + String(level)
        }
    }
}
