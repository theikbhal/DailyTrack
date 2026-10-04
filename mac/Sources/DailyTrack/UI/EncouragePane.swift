import SwiftUI

struct EncouragePane: View {
    @EnvironmentObject private var store: DayStore
    @EnvironmentObject private var game: Game
    @EnvironmentObject private var experiments: ExperimentsManager
    @EnvironmentObject private var theme: ThemeManager
    @State private var index = Int.random(in: 0..<EncouragePane.lines.count)
    @State private var flashText: String? = nil
    @State private var celebration = 0

    static let lines: [String] = [
        "Small and consistent beats big and rare. One count now is victory over procrastination.",
        "Your enemy is the pause before you start, not the work itself. Open the counter.",
        "1100 is only 11 hundreds. The abacus does not judge your pace, only your return.",
        "A kept day is 75 percent, not perfection. Saved is saved.",
        "The Prophet ﷺ said: the most beloved deeds to Allah are the most consistent, even if small.",
        "You have failed before and started again. That is not weakness, that is the pattern of winners.",
        "Two rakat and a single astaghfar restart the day. No guilt, just restart.",
        "Your family is watching how you recover, not how you fall.",
        "Sleep, zikir, work. Rotate the wheel instead of breaking it.",
        "Laziness loses health when you log a single tracker. Damage it now."
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                quoteCard
                if experiments.isEnabled("rewards") { boostCard }
                statusCard
            }
            .padding()
        }
        .navigationTitle("Encourage")
        .overlay(alignment: .top) { ConfettiBurst(trigger: celebration) }
    }

    private var quoteCard: some View {
        Card(title: "For you right now", icon: "quote.opening") {
            VStack(alignment: .leading, spacing: 12) {
                Text(EncouragePane.lines[index])
                    .font(.title3)
                    .fixedSize(horizontal: false, vertical: true)
                HStack {
                    Button("Another one") {
                        index = (index + 1) % EncouragePane.lines.count
                    }
                    .buttonStyle(.borderedProminent)
                    Spacer()
                    Pill(text: "\(index + 1) of \(EncouragePane.lines.count)", color: theme.current.accent)
                }
            }
        }
    }

    private var boostCard: some View {
        Card(title: "Push through", icon: "bolt.fill") {
            VStack(alignment: .leading, spacing: 10) {
                Text("Spends 2 energy, earns 25 XP and 5 coins. Use it when you are about to close the app.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                HStack {
                    Pill(text: "Energy \(game.state.energy)/\(game.state.maxEnergy)", color: .green)
                    Pill(text: "\(game.state.coins) coins", color: .yellow)
                    Spacer()
                    Button("Push through (-2 energy)") {
                        if game.pushThrough() {
                            flashText = "Boost taken - now do one tracker before you switch tasks."
                            if experiments.isEnabled("confetti") { celebration += 1 }
                        } else {
                            flashText = "No energy left. Buy energy with 30 coins, or wait for the 30 minute refill."
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    if game.state.coins >= 30 && game.state.energy < game.state.maxEnergy {
                        Button("Buy energy (30 coins)") {
                            flashText = game.buyEnergy() ? "Energy refilled." : "Not enough coins."
                        }
                        .buttonStyle(.bordered)
                    }
                }
                if let flashText {
                    Text(flashText).font(.caption.bold()).foregroundStyle(theme.current.accent)
                }
            }
        }
    }

    private var statusCard: some View {
        Card(title: "Where you stand", icon: "figure.stand") {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Pill(text: "streak \(store.currentStreak())", color: .purple)
                    Pill(text: "today \(Int(store.score() * 100))%", color: theme.current.accent)
                    Pill(text: "level \(game.level.level)", color: .blue)
                    Spacer()
                }
                Text(store.isKept()
                     ? "Kept. Tomorrow you start from zero again - same time, same order."
                     : "Still open. The fastest way back is the counter, right now, for two minutes.")
                    .font(.callout)
                if experiments.isEnabled("enemies") {
                    ForEach(game.bosses(store: store)) { boss in
                        HStack {
                            Image(systemName: boss.icon).foregroundStyle(.red)
                            Text("\(boss.title) at \(Int(boss.hp)) HP").font(.caption)
                            Spacer()
                            Bar(progress: boss.hp / boss.max, color: .red, height: 6).frame(width: 140)
                        }
                    }
                }
            }
        }
    }
}
