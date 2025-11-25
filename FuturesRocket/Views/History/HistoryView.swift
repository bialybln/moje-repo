import SwiftUI

struct HistoryView: View {
    @ObservedObject var appState: AppState
    @StateObject private var viewModel: HistoryViewModel

    init(appState: AppState) {
        self.appState = appState
        _viewModel = StateObject(wrappedValue: HistoryViewModel(appState: appState))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                progressHeader
                ForEach(viewModel.trades) { trade in
                    NavigationLink(destination: TradeDetailView(trade: trade).environmentObject(appState)) {
                        tradeRow(trade)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .background(AppColors.primaryBackground.ignoresSafeArea())
        .navigationTitle("History")
    }

    private var progressHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Capital journey")
                .font(AppTypography.titleSmall)
                .foregroundColor(AppColors.textPrimary)
            Text("Goal: " + viewModel.targetCapital.formatted(.currency(code: "USD")))
                .font(AppTypography.bodySecondary)
                .foregroundColor(AppColors.textSecondary)
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: "151515"))
                    .frame(height: 26)
                GeometryReader { geometry in
                    let width = geometry.size.width * viewModel.capitalProgress
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd], startPoint: .leading, endPoint: .trailing))
                        .frame(width: width, height: 26)
                        .animation(.easeInOut(duration: 0.8), value: viewModel.capitalProgress)
                    Image("LilBuddy")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                        .offset(x: width - 16)
                        .animation(.easeInOut(duration: 0.8), value: viewModel.capitalProgress)
                        .scaleEffect(1 + 0.05 * sin(viewModel.capitalProgress * 3.14))
                }
                .frame(height: 32)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(20)
    }

    private func tradeRow(_ trade: SavedTrade) -> some View {
        GlassCard {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(trade.symbol)
                        .font(AppTypography.titleSmall)
                        .foregroundColor(AppColors.textPrimary)
                    Text(viewModel.subtitle(for: trade))
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(trade.dateClosed, format: .dateTime.day().month().year())
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                    Text(trade.realizedPnL, format: .currency(code: "USD"))
                        .font(AppTypography.bodyPrimary)
                        .foregroundColor(trade.realizedPnL >= 0 ? AppColors.profit : AppColors.loss)
                }
            }
        }
    }
}
