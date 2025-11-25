import SwiftUI

struct SettingsView: View {
    @ObservedObject var appState: AppState
    @StateObject private var viewModel: SettingsViewModel

    init(appState: AppState) {
        self.appState = appState
        _viewModel = StateObject(wrappedValue: SettingsViewModel(appState: appState))
    }

    var body: some View {
        Form {
            Section(header: Text("Risk & Capital")) {
                HStack {
                    Text("Initial capital")
                    Spacer()
                    TextField("Initial capital", value: $viewModel.settings.initialCapital, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Current capital")
                    Spacer()
                    Text(viewModel.settings.currentCapital, format: .currency(code: "USD"))
                    Button("Reset") { viewModel.resetToInitialCapital() }
                }
                VStack(alignment: .leading) {
                    Text("Risk per trade (%)")
                    Slider(value: $viewModel.settings.riskPercent, in: 0...10, step: 0.25)
                    Text(viewModel.settings.riskPercent, format: .number)
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            Section(header: Text("Capital goal")) {
                HStack {
                    Text("Target capital")
                    Spacer()
                    TextField("Target", value: $viewModel.settings.targetCapital, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppColors.primaryBackground)
        .navigationTitle("Settings")
    }
}
