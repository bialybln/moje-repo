import SwiftUI
import UIKit

struct HomeView: View {
    @ObservedObject var appState: AppState
    @StateObject private var viewModel: CalculatorViewModel
    @State private var showingSaveSheet = false
    @State private var showConfetti = false

    init(appState: AppState) {
        self.appState = appState
        _viewModel = StateObject(wrappedValue: CalculatorViewModel(appState: appState))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                GradientHeaderView(
                    title: "Capital",
                    subtitle: "Current balance",
                    amount: appState.settings.currentCapital.formatted(.currency(code: "USD"))
                )
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "person.circle")
                        .foregroundColor(.white.opacity(0.9))
                        .padding()
                        .font(.title2)
                }

                calculatorSection
                takeProfitSection
                summarySection
            }
            .padding(.bottom, 32)
        }
        .background(AppColors.primaryBackground.ignoresSafeArea())
        .sheet(isPresented: $showingSaveSheet) {
            SaveTradeSheetView(viewModel: viewModel) { outcome in
                let trade = viewModel.buildSavedTrade(outcome: outcome, settings: appState.settings)
                var updatedSettings = appState.settings
                updatedSettings.currentCapital += trade.realizedPnL
                appState.update(settings: updatedSettings)
                appState.add(trade: trade)
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                showConfetti = true
            }
        }
    }

    private var calculatorSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Position Calculator")
                        .font(AppTypography.titleSmall)
                        .foregroundColor(AppColors.textPrimary)
                    Spacer()
                    Picker("Direction", selection: $viewModel.direction) {
                        ForEach(TradeDirection.allCases) { direction in
                            Text(direction.displayName).tag(direction)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 160)
                }

                inputField(title: "Symbol", value: $viewModel.symbol, icon: "chart.bar.doc.horizontal.fill")
                numericField(title: "Entry price", value: $viewModel.entryPrice, icon: "arrow.down.circle")
                numericField(title: "Stop loss", value: $viewModel.stopLoss, icon: "shield.lefthalf.filled")

                HStack {
                    Text("DCA entries")
                        .font(AppTypography.bodyPrimary)
                        .foregroundColor(AppColors.textPrimary)
                    Spacer()
                    Button(action: viewModel.addDCA) {
                        Label("Add", systemImage: "plus.circle.fill")
                    }
                    .buttonStyle(.borderless)
                    .foregroundColor(AppColors.gradientEnd)
                }

                ForEach(viewModel.dcaEntries) { entry in
                    HStack {
                        numericField(title: "Price", value: Binding(
                            get: { entry.price },
                            set: { price in
                                if let index = viewModel.dcaEntries.firstIndex(where: { $0.id == entry.id }) {
                                    viewModel.dcaEntries[index].price = price
                                }
                            }
                        ), icon: "arrow.down.circle")
                        numericField(title: "Risk %", value: Binding(
                            get: { entry.riskSharePercent },
                            set: { percent in
                                if let index = viewModel.dcaEntries.firstIndex(where: { $0.id == entry.id }) {
                                    viewModel.dcaEntries[index].riskSharePercent = percent
                                }
                            }
                        ), icon: "percent")
                        Button(action: { viewModel.removeDCA(entry) }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(AppColors.loss)
                        }
                    }
                }

                if let validation = viewModel.validationMessage(settings: appState.settings) {
                    Text(validation)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.loss)
                }
            }
        }
    }

    private var takeProfitSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Take profit ladder")
                        .font(AppTypography.titleSmall)
                        .foregroundColor(AppColors.textPrimary)
                    Spacer()
                    Button(action: viewModel.addTakeProfit) {
                        Label("Add TP", systemImage: "plus.circle.fill")
                    }
                    .foregroundColor(AppColors.gradientEnd)
                }

                ForEach(viewModel.takeProfits) { tp in
                    HStack {
                        numericField(title: "TP Price", value: Binding(
                            get: { tp.tpPrice },
                            set: { newValue in
                                if let index = viewModel.takeProfits.firstIndex(where: { $0.id == tp.id }) {
                                    viewModel.takeProfits[index].tpPrice = newValue
                                }
                            }
                        ), icon: "arrow.up.circle")
                        numericField(title: "% Trim", value: Binding(
                            get: { tp.trimPercentOfPosition },
                            set: { newValue in
                                if let index = viewModel.takeProfits.firstIndex(where: { $0.id == tp.id }) {
                                    viewModel.takeProfits[index].trimPercentOfPosition = newValue
                                }
                            }
                        ), icon: "scissors")
                        if let units = viewModel.trimmedUnits[tp.id] {
                            Text(units, format: .number.precision(.fractionLength(2)))
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        Button(action: { viewModel.removeTakeProfit(tp) }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(AppColors.loss)
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }

    private var summarySection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Total units")
                        .foregroundColor(AppColors.textSecondary)
                        .font(AppTypography.bodySecondary)
                    Spacer()
                    Text(viewModel.totalUnits, format: .number.precision(.fractionLength(3)))
                        .font(AppTypography.titleSmall)
                        .foregroundColor(AppColors.textPrimary)
                        .scaleEffect(showConfetti ? 1.05 : 1)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showConfetti)
                }
                HStack {
                    Text("Avg entry")
                        .foregroundColor(AppColors.textSecondary)
                    Spacer()
                    Text(viewModel.averageEntry, format: .currency(code: "USD"))
                        .foregroundColor(AppColors.textPrimary)
                }
                HStack {
                    Text("Risk per trade")
                        .foregroundColor(AppColors.textSecondary)
                    Spacer()
                    Text(viewModel.riskAmount, format: .currency(code: "USD"))
                        .foregroundColor(AppColors.textPrimary)
                }

                Button {
                    showingSaveSheet = true
                } label: {
                    Text("Save trade")
                        .font(AppTypography.titleSmall)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd], startPoint: .leading, endPoint: .trailing)
                                .cornerRadius(16)
                        )
                        .foregroundColor(.white)
                        .shadow(color: AppColors.gradientEnd.opacity(0.4), radius: 12, x: 0, y: 8)
                }
                .padding(.top, 8)
            }
        }
    }

    private func inputField(title: String, value: Binding<String>, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(AppTypography.bodySecondary)
                .foregroundColor(AppColors.textSecondary)
            HStack {
                Image(systemName: icon)
                    .foregroundColor(AppColors.textSecondary)
                TextField(title, text: value)
                    .font(AppTypography.bodyPrimary)
                    .foregroundColor(AppColors.textPrimary)
            }
            .padding(14)
            .background(AppColors.cardBackground)
            .cornerRadius(16)
        }
    }

    private func numericField(title: String, value: Binding<Double>, icon: String) -> some View {
        inputField(title: title, value: Binding(
            get: { String(value.wrappedValue) },
            set: { newValue in
                value.wrappedValue = Double(newValue) ?? value.wrappedValue
            }
        ), icon: icon)
    }
}
