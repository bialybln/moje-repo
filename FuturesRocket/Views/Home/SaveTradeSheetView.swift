import SwiftUI

struct SaveTradeSheetView: View {
    @ObservedObject var viewModel: CalculatorViewModel
    var onSave: (TradeOutcome) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var outcome: TradeOutcome = .stopLoss
    @State private var reachedLevels: Int = 1

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("How was the trade closed?")) {
                    Picker("Outcome", selection: Binding(
                        get: { outcomeTag },
                        set: { tag in
                            outcome = outcomeFromTag(tag)
                        }
                    )) {
                        Text("SL").tag("sl")
                        Text("BE").tag("be")
                        Text("TP").tag("tp")
                    }
                    .pickerStyle(.segmented)

                    if case .takeProfit = outcome {
                        Stepper(value: $reachedLevels, in: 1...max(1, viewModel.takeProfits.count)) {
                            Text("Levels reached: \(reachedLevels)")
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppColors.primaryBackground)
            .navigationTitle("Save trade")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let finalOutcome: TradeOutcome
                        switch outcome {
                        case .stopLoss: finalOutcome = .stopLoss
                        case .breakEven: finalOutcome = .breakEven
                        case .takeProfit: finalOutcome = .takeProfit(reachedLevels: reachedLevels)
                        }
                        onSave(finalOutcome)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: { dismiss() })
                }
            }
        }
    }

    private var outcomeTag: String {
        switch outcome {
        case .stopLoss: return "sl"
        case .breakEven: return "be"
        case .takeProfit: return "tp"
        }
    }

    private func outcomeFromTag(_ tag: String) -> TradeOutcome {
        switch tag {
        case "be": return .breakEven
        case "tp": return .takeProfit(reachedLevels: reachedLevels)
        default: return .stopLoss
        }
    }
}
