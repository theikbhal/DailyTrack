import Foundation
import SwiftUI

@main
struct DailyTrackApp: App {
    @StateObject private var store = DayStore()
    @StateObject private var game = Game.shared
    @StateObject private var settings = AppSettings.shared
    @StateObject private var experiments = ExperimentsManager.shared
    @StateObject private var theme = ThemeManager.shared
    @StateObject private var appState = AppState()

    init() {
        if CommandLine.arguments.contains("--selftest") {
            exit(SelfTest.run())
        }
        if CommandLine.arguments.contains("--plan") {
            print(SelfTest.planText())
            exit(0)
        }
    }

    var body: some Scene {
        WindowGroup("DailyTrack") {
            RootView()
                .environmentObject(store)
                .environmentObject(game)
                .environmentObject(settings)
                .environmentObject(experiments)
                .environmentObject(theme)
                .environmentObject(appState)
                .onAppear { bootstrap() }
        }
        .defaultSize(width: 1140, height: 780)
        .commands {
            CommandMenu("Day") {
                Button("Go to Today") { appState.tab = .today }.keyboardShortcut("1", modifiers: .command)
                Button("Go to Calendar") { appState.tab = .calendar }.keyboardShortcut("2", modifiers: .command)
                Button("Go to Progress") { appState.tab = .progress }.keyboardShortcut("3", modifiers: .command)
                Button("Go to Encourage") { appState.tab = .encourage }.keyboardShortcut("4", modifiers: .command)
                Button("Go to Help") { appState.tab = .help }.keyboardShortcut("5", modifiers: .command)
                Button("Go to Settings") { appState.tab = .settings }.keyboardShortcut("6", modifiers: .command)
                Divider()
                Button("Reset onboarding") {
                    settings.onboardingDone = false
                    appState.showOnboarding = true
                }.keyboardShortcut("o", modifiers: [.command, .shift])
                Button("Send test notification") {
                    NotificationEngine.shared.sendTest()
                }.keyboardShortcut("t", modifiers: [.command, .shift])
            }
        }

    }

    private func bootstrap() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            NotificationEngine.shared.requestPermission()
            NotificationEngine.shared.reschedule(settings)
            game.reconcile(store: store)
        }
        NotificationCenter.default.addObserver(forName: NSApplication.didBecomeActiveNotification,
                                                object: nil, queue: .main) { _ in
            game.reconcile(store: store)
        }
    }
}
