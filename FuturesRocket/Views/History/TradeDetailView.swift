import SwiftUI

struct TradeDetailView: View {
    @EnvironmentObject private var appState: AppState
    @State private var trade: SavedTrade

    init(trade: SavedTrade) {
        _trade = State(initialValue: trade)
    }

    var body: some View {
        Form {
            Section(header: Text("Summary")) {
                HStack { Text("Direction"); Spacer(); Text(trade.direction.displayName) }
                HStack { Text("Entry"); Spacer(); Text(trade.entryPrice, format: .currency(code: "USD")) }
                HStack { Text("Stop loss"); Spacer(); Text(trade.stopLoss, format: .currency(code: "USD")) }
                HStack { Text("Outcome"); Spacer(); Text(outcomeText) }
                HStack { Text("Realized PnL"); Spacer(); Text(trade.realizedPnL, format: .currency(code: "USD")).foregroundColor(trade.realizedPnL >= 0 ? AppColors.profit : AppColors.loss) }
            }

            Section(header: Text("DCA")) {
                ForEach(trade.dcaEntries) { entry in
                    HStack {
                        Text(entry.price, format: .currency(code: "USD"))
                        Spacer()
                        Text(entry.riskSharePercent, format: .number)
                        Text("%")
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }

            Section(header: Text("Take profit")) {
                ForEach(trade.takeProfits) { tp in
                    HStack {
                        Text(tp.tpPrice, format: .currency(code: "USD"))
                        Spacer()
                        Text(tp.trimPercentOfPosition, format: .number)
                        Text("%")
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }

            Section(header: Text("Note")) {
                TextEditor(text: Binding(
                    get: { trade.note ?? "" },
                    set: { trade.note = $0 }
                ))
                .frame(height: 120)
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppColors.primaryBackground)
        .navigationTitle(trade.symbol)
        .toolbar {
            Button("Done") {
                appState.update(trade: trade)
            }
        }
    }

    private var outcomeText: String {
        switch trade.outcome {
        case .stopLoss: return "SL"
        case .breakEven: return "BE"
        case .takeProfit(let level): return "TP\(level)"
        }
    }
}
