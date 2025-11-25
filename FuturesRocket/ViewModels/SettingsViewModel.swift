import Foundation
import Combine
import SwiftUI

/// Handles persistence and validation for the Settings tab.
final class SettingsViewModel: ObservableObject {
    @Published var settings: AppSettings

    private let appState: AppState
    private var cancellables = Set<AnyCancellable>()

    init(appState: AppState) {
        self.appState = appState
        self.settings = appState.settings

        $settings
            .dropFirst()
            .debounce(for: .milliseconds(150), scheduler: DispatchQueue.main)
            .sink { [weak self] newSettings in
                self?.appState.update(settings: newSettings)
            }
            .store(in: &cancellables)
    }

    func resetToInitialCapital() {
        settings.currentCapital = settings.initialCapital
    }
}
