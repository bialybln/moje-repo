import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        TabView {
            NavigationStack { HomeView(appState: appState) }
                .tabItem {
                    Label("Home", systemImage: "chart.line.uptrend.xyaxis")
                }
            NavigationStack { HistoryView(appState: appState) }
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
            NavigationStack { SettingsView(appState: appState) }
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .accentColor(AppColors.gradientEnd)
    }
}
