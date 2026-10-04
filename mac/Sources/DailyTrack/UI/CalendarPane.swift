import SwiftUI

struct CalendarPane: View {
    enum Mode: String, CaseIterable {
        case day, week, month, year
    }

    @EnvironmentObject private var store: DayStore
    @EnvironmentObject private var experiments: ExperimentsManager
    @EnvironmentObject private var theme: ThemeManager
    @State private var mode: Mode = .month
    @State private var selected = Date()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                header
                switch mode {
                case .day: dayView
                case .week: weekView
                case .month: monthView
                case .year: yearView
                }
            }
            .padding()
        }
        .navigationTitle("Calendar")
    }

    private var header: some View {
        Card(title: titleText, icon: "calendar") {
            HStack {
                Picker("", selection: $mode) {
                    ForEach(Mode.allCases, id: \.self) { Text($0.rawValue.capitalized).tag($0) }
                }
                .labelsHidden()
                .pickerStyle(.segmented)
                Spacer()
                Button(action: { shift(-1) }) { Image(systemName: "chevron.left") }
                    .buttonStyle(.bordered).controlSize(.small)
                Button("Today") { selected = Date() }.buttonStyle(.bordered).controlSize(.small)
                Button(action: { shift(1) }) { Image(systemName: "chevron.right") }
                    .buttonStyle(.bordered).controlSize(.small)
            }
        }
    }

    private var titleText: String {
        switch mode {
        case .day: return Fmt.long.string(from: selected)
        case .week: return "Week of " + Fmt.long.string(from: store.weekDays(selected).first ?? selected)
        case .month: return monthFormatter.string(from: selected)
        case .year: return yearFormatter.string(from: selected)
        }
    }

    private var monthFormatter: DateFormatter {
        let f = DateFormatter(); f.dateFormat = "MMMM yyyy"; return f
    }

    private var yearFormatter: DateFormatter {
        let f = DateFormatter(); f.dateFormat = "yyyy"; return f
    }

    private func shift(_ delta: Int) {
        let cal = Calendar.current
        let comp: Calendar.Component = mode == .day ? .day : mode == .week ? .weekOfYear : mode == .month ? .month : .year
        if let d = cal.date(byAdding: comp, value: delta, to: selected) { selected = d }
    }

    private func color(for score: Double) -> Color {
        if score >= 0.999 { return theme.current.accent }
        if score >= 0.75 { return theme.current.accent.opacity(0.65) }
        if score > 0 { return theme.current.accent.opacity(0.3) }
        return Color.gray.opacity(0.18)
    }

    private var dayView: some View {
        Card(title: "Day detail", icon: "doc.text") {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    StatCard(title: "Score", value: "\(Int(store.score(selected) * 100))%", color: theme.current.accent)
                    StatCard(title: "Status", value: store.isKept(selected) ? "Kept" : "Open",
                             color: store.isKept(selected) ? .green : .orange)
                }
                ForEach(store.enabled()) { t in
                    HStack {
                        Image(systemName: t.icon).foregroundStyle(theme.current.accent).frame(width: 22)
                        Text(t.title).font(.callout)
                        Spacer()
                        Text("\(store.value(t.id, selected)) / \(t.target)")
                            .font(.callout.bold())
                            .foregroundStyle(store.progress(t, selected) >= 1 ? .green : .primary)
                    }
                    Divider()
                }
            }
        }
    }

    private var weekView: some View {
        Card(title: "Week", icon: "calendar.badge.clock") {
            VStack(spacing: 8) {
                HStack {
                    ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { d in
                        Text(d).font(.caption.bold()).foregroundStyle(.secondary).frame(maxWidth: .infinity)
                    }
                }
                HStack {
                    ForEach(Array(store.weekDays(selected).enumerated()), id: \.offset) { _, day in
                        let s = store.score(day)
                        VStack {
                            Text("\(Calendar.current.component(.day, from: day))")
                                .font(.callout.bold())
                            Text("\(Int(s * 100))").font(.system(size: 9))
                        }
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(color(for: s), in: RoundedRectangle(cornerRadius: 8))
                    }
                }
                Text("Week kept days: \(store.weekDays(selected).filter { store.isKept($0) }.count) of 7")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    private var monthView: some View {
        Card(title: "Month", icon: "calendar") {
            let cal = Calendar.current
            let days = monthDays()
            let kept = days.filter { store.isKept($0) }.count
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    StatCard(title: "Days kept", value: "\(kept)", color: .green)
                    StatCard(title: "Days with data", value: "\(days.filter { store.score($0) > 0 }.count)", color: theme.current.accent)
                    StatCard(title: "Perfect", value: "\(days.filter { store.isPerfect($0) }.count)", color: .purple)
                }
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 6) {
                    ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { d in
                        Text(d).font(.caption2.bold()).foregroundStyle(.secondary)
                    }
                    ForEach(Array(days.enumerated()), id: \.offset) { _, day in
                        let s = store.score(day)
                        VStack(spacing: 0) {
                            Text("\(cal.component(.day, from: day))").font(.system(size: 11, weight: .semibold))
                            Text("\(Int(s * 100))").font(.system(size: 8))
                        }
                        .frame(maxWidth: .infinity, minHeight: 34)
                        .background(color(for: s), in: RoundedRectangle(cornerRadius: 6))
                        .opacity(cal.isDateInToday(day) ? 1 : 0.95)
                        .overlay(RoundedRectangle(cornerRadius: 6)
                            .stroke(cal.isDateInToday(day) ? Color.primary : .clear, lineWidth: 1.5))
                        .onTapGesture { selected = day; mode = .day }
                    }
                }
            }
        }
    }

    private func monthDays() -> [Date] {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: selected)
        guard let start = cal.date(from: comps),
              let range = cal.range(of: .day, in: .month, for: start) else { return [] }
        return range.compactMap { cal.date(byAdding: .day, value: $0 - 1, to: start) }
    }

    private var yearView: some View {
        Card(title: "Year", icon: "square.grid.3x3") {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                ForEach(1...12, id: \.self) { m in
                    let kept = monthKept(m)
                    VStack(spacing: 4) {
                        Text(monthShort(m)).font(.caption.bold())
                        Text("\(kept)").font(.title3.bold()).foregroundStyle(theme.current.accent)
                        Text("kept").font(.system(size: 9)).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                    .onTapGesture {
                        var c = DateComponents(); c.year = Calendar.current.component(.year, from: selected); c.month = m; c.day = 1
                        if let d = Calendar.current.date(from: c) { selected = d; mode = .month }
                    }
                }
            }
            Text("Longest streak: \(store.longestStreak()) days")
                .font(.caption).foregroundStyle(.secondary)
        }
    }

    private func monthKept(_ month: Int) -> Int {
        var c = DateComponents()
        c.year = Calendar.current.component(.year, from: selected)
        c.month = month
        c.day = 1
        guard let start = Calendar.current.date(from: c),
              let range = Calendar.current.range(of: .day, in: .month, for: start) else { return 0 }
        let days = range.compactMap { Calendar.current.date(byAdding: .day, value: $0 - 1, to: start) }
        return days.filter { store.isKept($0) }.count
    }

    private func monthShort(_ m: Int) -> String {
        let names = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        return names[m - 1]
    }
}
