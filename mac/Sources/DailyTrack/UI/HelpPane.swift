import SwiftUI

struct HelpPane: View {
    @State private var open: Set<String> = ["start"]

    private let sections: [(id: String, title: String, icon: String, body: [String])] = [
        ("start", "Getting started", "figure.walk",
         ["DailyTrack is a single-user daily dashboard: zikir, namaz, rest and life, in one screen.",
          "Open Today, tap the tracker you want. Counters use the abacus, checklists use +1, durations use 30 minute steps.",
          "A day is kept when your enabled daily trackers average at least 75 percent. Keep the streak alive."]),
        ("trackers", "The trackers", "list.bullet.rectangle",
         ["Darood 1100 and Astaghfar 1100 - the core zikir, counted on the abacus.",
          "Teen Tasbih 99 (33 x 3), 20 rakat nafil, Chash, Ishraq, Zuhr sunnat ghairullah (4 rakat with 30 minutes kept free).",
          "5 daily prayers, night sleep 4-5 hours, morning sleep 4 hours.",
          "Sunday holiday extra time, the daily Ismail bhai dryfruits call, madrasa visit once or twice a week.",
          "Every tracker can be switched off in Settings > Experiments - hide what you are not tracking yet."]),
        ("rewards", "Streaks, levels and badges", "rosette",
         ["Streak = consecutive kept days. Longest streak and total kept days live in Progress.",
          "XP comes from finishing trackers (+20), keeping a day (+50) and earning badges (+30).",
          "Eight levels: Newcomer, Consistent, Steady, Devoted, Disciplined, Focused, Master, Legend.",
          "Sixteen badges cover darood 1100, astaghfar 1100, teen tasbih, all five prayers, streaks and more.",
          "Coins are earned with every win; 30 coins buy a full energy refill."]),
        ("enemies", "Enemies and energy", "figure.martial.art",
         ["Laziness and Weak Health are two bosses with HP bars. Finishing zikir damages laziness, finishing rest damages weak health.",
          "A day you miss heals them by 15 HP, so consistency is literally combat.",
          "Energy refills one block every 30 minutes and grows with your level. Push through spends 2 energy for 25 XP.",
          "Both features live under Experiments if you want a calmer app."]),
        ("notifications", "Daily push notifications", "bell.badge",
         ["Three daily nudges: morning (default 6:00), midday (13:30) and evening (20:00).",
          "Each tracker completion fires a one-shot MashaAllah notification.",
          "Times and on/off live in Settings > Notifications, along with a test button.",
          "If macOS shows Blocked, allow DailyTrack in System Settings > Notifications."]),
        ("data", "Local data, export and import", "externaldrive",
         ["Everything is stored locally on this Mac under the dailytrack.* UserDefaults keys. Single user, no account.",
          "Export writes DailyTrack-Export.json or DailyTrack.csv to your Desktop.",
          "Import replaces your records with a previously exported JSON file.",
          "Turso cloud sync is an optional experiment: paste your DB URL and token in Settings > Sync."]),
        ("roadmap", "Roadmap", "map",
         ["Shipped in 1.0: 13 trackers with per-tracker experiment flags, abacus counter, calendar (day/week/month/year), streaks, levels, 16 badges, coins, energy, two enemies, daily push notifications, encouragement tab, onboarding, help, export and import, 8 themes including dark mode.",
          "1.1 next: prayer time aware reminders, menu bar quick-count, weekly review screen, iCloud JSON backup.",
          "1.2: hijri dates, Ramadan mode, Flutter mobile client on the same Wi-Fi, website view on Vercel.",
          "Known rough edges (bugs): the year view keeps the selected year only while the app is open; streaks treat all enabled trackers equally.",
          "Improvements wanted: drag-to-count on the abacus, per-tracker targets in Settings, richer enemy AI."]),
        ("faq", "FAQ", "questionmark.circle",
         ["Why 75 percent and not 100? Perfection breaks streaks. The minimum keeps you in the game.",
          "Can I change a target? Targets are fixed in 1.0; turn the tracker off instead.",
          "Where is my data? DailyTrack-Export.json on the Desktop after you export.",
          "Is there a phone app? The mobile/ Flutter folder in the repo is the start of it."])
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Card(title: "DailyTrack Help", icon: "book") {
                    Text("Built for one person with too many intentions and not enough follow-through: pick the minimum, keep the streak, ignore the rest.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                ForEach(sections, id: \.id) { section in
                    Card(title: section.title, icon: section.icon) {
                        VStack(alignment: .leading, spacing: 8) {
                            Button {
                                withAnimation { toggle(section.id) }
                            } label: {
                                HStack {
                                    Text(open.contains(section.id) ? "Hide" : "Read")
                                        .font(.callout.bold())
                                    Spacer()
                                    Image(systemName: open.contains(section.id) ? "chevron.up" : "chevron.down")
                                        .font(.caption)
                                }
                            }
                            .buttonStyle(.plain)
                            if open.contains(section.id) {
                                ForEach(section.body, id: \.self) { line in
                                    HStack(alignment: .top, spacing: 8) {
                                        Circle().fill(Color.accentColor).frame(width: 5, height: 5).padding(.top, 6)
                                        Text(line).font(.callout).fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Help")
    }

    private func toggle(_ id: String) {
        if open.contains(id) { open.remove(id) } else { open.insert(id) }
    }
}
