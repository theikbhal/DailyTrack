import SwiftUI

struct ProgressPane: View {
    @EnvironmentObject private var store: DayStore
    @EnvironmentObject private var game: Game
    @EnvironmentObject private var experiments: ExperimentsManager
    @EnvironmentObject private var theme: ThemeManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                if experiments.isEnabled("rewards") { levelCard; statsCard }
                streakCard
                last14Card
                if experiments.isEnabled("enemies") { enemiesCard }
                badgesCard
            }
            .padding()
        }
        .navigationTitle("Progress")
    }

    private var levelCard: some View {
        Card(title: "Level \(game.level.level) - \(game.level.name)", icon: "chart.line.uptrend.xyaxis") {
            VStack(alignment: .leading, spacing: 8) {
                Bar(progress: Levels.progress(game.state.xp), color: theme.current.accent, height: 10)
                HStack {
                    Text("\(game.state.xp) XP")
                    Spacer()
                    if game.level.level < Levels.thresholds.count {
                        Text("\(game.level.next - game.state.xp) XP to next level")
                    } else {
                        Text("Max level")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                HStack(spacing: 10) {
                    Pill(text: "\(game.state.coins) coins", color: .yellow)
                    Pill(text: "Energy \(game.state.energy)/\(game.state.maxEnergy)", color: .green)
                    Pill(text: "\(game.state.totalCounts) lifetime counts", color: .teal)
                }
            }
        }
    }

    private var statsCard: some View {
        Card(title: "Numbers", icon: "number") {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                StatCard(title: "Current streak", value: "\(store.currentStreak())", color: .purple)
                StatCard(title: "Longest streak", value: "\(store.longestStreak())", color: .orange)
                StatCard(title: "Days kept", value: "\(store.keptDaysCount())", color: .green)
                StatCard(title: "Badges", value: "\(game.state.badges.count)/\(Game.badgeDefs().count)", color: .blue)
            }
        }
    }

    private var streakCard: some View {
        Card(title: "Streak", icon: "flame.fill") {
            VStack(alignment: .leading, spacing: 8) {
                Text(store.isKept()
                     ? "Today is kept. Come back tomorrow to grow the streak."
                     : "Today is still open - add counts until the average hits 75 percent.")
                    .font(.callout)
                HStack {
                    Pill(text: "current \(store.currentStreak())", color: .purple)
                    Pill(text: "longest \(store.longestStreak())", color: .orange)
                    Pill(text: "kept \(store.keptDaysCount()) days", color: .green)
                }
            }
        }
    }

    private var last14Card: some View {
        Card(title: "Last 14 days", icon: "chart.bar.fill") {
            HStack(alignment: .bottom, spacing: 6) {
                ForEach(Array(store.scoreSeries(last: 14).enumerated()), id: \.offset) { _, item in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(item.1 >= 0.75 ? theme.current.accent : theme.current.accent.opacity(0.3))
                            .frame(height: max(6, 90 * item.1))
                        Text(dayLetter(item.0))
                            .font(.system(size: 8))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 110)
        }
    }

    private func dayLetter(_ d: Date) -> String {
        let cal = Calendar.current
        let names = ["S", "M", "T", "W", "T", "F", "S"]
        return names[cal.component(.weekday, from: d) - 1]
    }

    private var enemiesCard: some View {
        Card(title: "Enemies", icon: "figure.martial.art") {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(game.bosses(store: store)) { boss in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Label(boss.title, systemImage: boss.icon).font(.subheadline.bold())
                            Spacer()
                            Text("\(Int(boss.hp))/\(Int(boss.max)) HP")
                                .font(.caption).foregroundStyle(.secondary)
                            Pill(text: "x\(boss.wins)", color: .red)
                        }
                        Bar(progress: boss.hp / boss.max, color: .red, height: 10)
                    }
                }
                Text("Complete trackers to damage them. A missed day lets them heal.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var badgesCard: some View {
        Card(title: "Badges", icon: "rosette") {
            let unlocked = game.unlockedBadges()
            let locked = game.lockedBadges()
            VStack(alignment: .leading, spacing: 12) {
                if unlocked.isEmpty {
                    Text("No badges yet. Finish a tracker to earn the first one.")
                        .font(.callout).foregroundStyle(.secondary)
                }
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                    ForEach(unlocked, id: \.id) { badge in
                        VStack(spacing: 4) {
                            Image(systemName: badge.icon).font(.title2).foregroundStyle(theme.current.accent)
                            Text(badge.title).font(.caption.bold()).multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(theme.current.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                    }
                    ForEach(locked, id: \.id) { badge in
                        VStack(spacing: 4) {
                            Image(systemName: badge.icon).font(.title2).foregroundStyle(.gray.opacity(0.6))
                            Text(badge.title).font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
    }
}
