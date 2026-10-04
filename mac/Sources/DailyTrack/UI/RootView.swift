import SwiftUI

enum Tab: String, CaseIterable, Identifiable {
    case today, calendar, progress, encourage, help, settings
    var id: String { rawValue }

    var title: String {
        switch self {
        case .today: return "Today"
        case .calendar: return "Calendar"
        case .progress: return "Progress"
        case .encourage: return "Encourage"
        case .help: return "Help"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .today: return "checklist"
        case .calendar: return "calendar"
        case .progress: return "chart.line.uptrend.xyaxis"
        case .encourage: return "megaphone.fill"
        case .help: return "book"
        case .settings: return "gearshape.fill"
        }
    }
}

final class AppState: ObservableObject {
    @Published var tab: Tab = .today
    @Published var showOnboarding = false
}

struct RootView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var experiments: ExperimentsManager
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var game: Game

    var body: some View {
        NavigationSplitView {
            List(selection: $appState.tab) {
                ForEach(visibleTabs) { tab in
                    Label(tab.title, systemImage: tab.icon).tag(tab)
                }
            }
            .navigationTitle("DailyTrack")
            .safeAreaInset(edge: .bottom) {
                if experiments.isEnabled("rewards") {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Lv \(game.level.level) \(game.level.name)")
                                .font(.caption.bold())
                            Bar(progress: Levels.progress(game.state.xp), color: theme.current.accent, height: 5)
                        }
                        Spacer()
                        Pill(text: "\(game.state.coins)c", color: .yellow)
                    }
                    .padding(10)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
                }
            }
        } detail: {
            switch appState.tab {
            case .today: TodayView()
            case .calendar: CalendarPane()
            case .progress: ProgressPane()
            case .encourage: EncouragePane()
            case .help: HelpPane()
            case .settings: SettingsPane()
            }
        }
        .tint(theme.current.accent)
        .preferredColorScheme(theme.current.colorScheme)
        .sheet(isPresented: $appState.showOnboarding) {
            OnboardingView()
                .environmentObject(settings)
                .environmentObject(theme)
        }
        .onAppear {
            if !settings.onboardingDone && experiments.isEnabled("onboarding") {
                appState.showOnboarding = true
            }
        }
    }

    private var visibleTabs: [Tab] {
        var tabs: [Tab] = [.today]
        if experiments.isEnabled("calendar") { tabs.append(.calendar) }
        tabs.append(.progress)
        if experiments.isEnabled("encourage") { tabs.append(.encourage) }
        tabs.append(.help)
        tabs.append(.settings)
        return tabs
    }
}
