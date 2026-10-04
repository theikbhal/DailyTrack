import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var store: DayStore
    @EnvironmentObject private var game: Game
    @EnvironmentObject private var experiments: ExperimentsManager
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var theme: ThemeManager
    @State private var celebration = 0
    @State private var toast: String? = nil

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    header
                    if store.enabled().isEmpty {
                        Card(title: "Nothing enabled", icon: "slider.horizontal.3") {
                            Text("Open Settings and switch on the trackers you want under Experiments.")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                    }
                    ForEach(Catalog.categories) { cat in
                        let list = store.enabled().filter { $0.category == cat }
                        if !list.isEmpty {
                            SectionHeader(text: cat.label)
                            ForEach(list) { tracker in
                                card(for: tracker)
                            }
                        }
                    }
                }
                .padding()
            }
            if let toast {
                Text(toast)
                    .font(.callout.bold())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            ConfettiBurst(trigger: celebration)
        }
        .navigationTitle("Today")
        .animation(.spring(duration: 0.3), value: toast)
    }

    private var header: some View {
        Card(title: Fmt.long.string(from: Date()), icon: "calendar") {
            HStack(spacing: 16) {
                ZStack {
                    ProgressRing(progress: store.score(), color: theme.current.accent, lineWidth: 12)
                    Text("\(Int(store.score() * 100))%")
                        .font(.headline.bold())
                }
                .frame(width: 76, height: 76)
                VStack(alignment: .leading, spacing: 6) {
                    Text(greeting()).font(.title3.bold())
                    HStack(spacing: 8) {
                        Pill(text: store.isKept() ? "Day kept" : "In progress",
                             color: store.isKept() ? .green : .orange)
                        Pill(text: "\(store.currentStreak()) day streak", color: .purple)
                        if experiments.isEnabled("rewards") {
                            Pill(text: "Lv \(game.level.level) \(game.level.name)", color: theme.current.accent)
                        }
                    }
                    Text(store.isKept()
                         ? "MashaAllah - your minimum is secured. Everything above is reward."
                         : "Keep adding - a day counts when the enabled trackers average 75 percent.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
        }
    }

    private func greeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        let who = settings.name.isEmpty ? "" : ", " + settings.name
        switch hour {
        case 5..<12: return "Good morning\(who)"
        case 12..<17: return "Good afternoon\(who)"
        case 17..<22: return "Good evening\(who)"
        default: return "Late night\(who)"
        }
    }

    @ViewBuilder
    private func card(for t: Tracker) -> some View {
        if t.kind == .counter && t.abacus && experiments.isEnabled("abacus") {
            AbacusCounterCard(tracker: t, value: store.value(t.id), onChange: { update(t, $0) },
                              experiments: experiments)
                .environmentObject(theme)
        } else if t.kind == .counter {
            counterCard(t)
        } else if t.kind == .duration {
            durationCard(t)
        } else {
            checklistCard(t)
        }
    }

    private func counterCard(_ t: Tracker) -> some View {
        let value = store.value(t.id)
        return Card(title: t.title, icon: t.icon) {
            VStack(alignment: .leading, spacing: 8) {
                Text(t.detail).font(.caption).foregroundStyle(.secondary)
                HStack(alignment: .firstTextBaseline) {
                    Text("\(value) / \(t.target) \(t.unit)").font(.title3.bold())
                    Spacer()
                    if t.schedule == .weekly {
                        Pill(text: "this week: \(store.weekValue(t))", color: .teal)
                    }
                }
                Bar(progress: t.schedule == .weekly ? store.weekProgress(t) : Double(value) / Double(t.target),
                    color: theme.current.accent)
                HStack {
                    Button("-1") { update(t, max(0, value - 1)) }.buttonStyle(.bordered).controlSize(.small)
                    Button("+1") { update(t, value + 1) }.buttonStyle(.borderedProminent).controlSize(.small)
                    Button("+2") { update(t, value + 2) }.buttonStyle(.bordered).controlSize(.small)
                    Spacer()
                    DoneButton(done: value >= t.target) { update(t, t.target) }
                }
            }
        }
    }

    private func checklistCard(_ t: Tracker) -> some View {
        let value = store.value(t.id)
        let weekly = t.schedule == .weekly
        let progress = weekly ? store.weekProgress(t) : Double(value) / Double(t.target)
        return Card(title: t.title, icon: t.icon) {
            VStack(alignment: .leading, spacing: 8) {
                Text(t.detail).font(.caption).foregroundStyle(.secondary)
                HStack(alignment: .firstTextBaseline) {
                    Text("\(value) / \(t.target) \(t.unit)").font(.title3.bold())
                    Spacer()
                    if weekly { Pill(text: "week total", color: .teal) }
                }
                Bar(progress: progress, color: theme.current.accent)
                HStack {
                    Button("-1") { update(t, max(0, value - 1)) }.buttonStyle(.bordered).controlSize(.small)
                    Button("+1") { update(t, value + 1) }.buttonStyle(.borderedProminent).controlSize(.small)
                    Spacer()
                    DoneButton(done: value >= t.target) { update(t, t.target) }
                }
            }
        }
    }

    private func durationCard(_ t: Tracker) -> some View {
        let value = store.value(t.id)
        return Card(title: t.title, icon: t.icon) {
            VStack(alignment: .leading, spacing: 8) {
                Text(t.detail).font(.caption).foregroundStyle(.secondary)
                HStack(alignment: .firstTextBaseline) {
                    Text(hoursText(value)).font(.title3.bold())
                    Text("/ \(hoursText(t.target))").foregroundStyle(.secondary)
                    Spacer()
                }
                Bar(progress: Double(value) / Double(t.target), color: theme.current.accent)
                HStack {
                    Button("-30 min") { update(t, max(0, value - 30)) }.buttonStyle(.bordered).controlSize(.small)
                    Button("+30 min") { update(t, value + 30) }.buttonStyle(.borderedProminent).controlSize(.small)
                    Spacer()
                    DoneButton(done: value >= t.target) { update(t, t.target) }
                }
            }
        }
    }

    private func hoursText(_ minutes: Int) -> String {
        "\(minutes / 60)h \(minutes % 60)m"
    }

    private func update(_ t: Tracker, _ newValue: Int) {
        let old = store.value(t.id)
        guard newValue != old else { return }
        store.set(t.id, newValue)
        game.valueChanged(t: t, old: old, new: newValue)
        if old < t.target && newValue >= t.target {
            if experiments.isEnabled("confetti") { celebration += 1 }
            NotificationEngine.shared.sendLive(id: "dailytrack.done.\(t.id).\(Fmt.day.string(from: Date()))",
                                               title: "MashaAllah",
                                               body: "\(t.title) is complete for today.")
            flash("\(t.title) complete - MashaAllah")
        }
        game.reconcile(store: store)
    }

    private func flash(_ text: String) {
        withAnimation { toast = text }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            withAnimation { if toast == text { toast = nil } }
        }
    }
}

struct DoneButton: View {
    let done: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Label(done ? "Done" : "Mark done", systemImage: done ? "checkmark.circle.fill" : "checkmark.circle")
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
        .tint(done ? .green : nil)
    }
}
