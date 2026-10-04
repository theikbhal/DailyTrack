import Foundation
import Combine

struct DayBlob: Codable {
    var version = 1
    var exportedAt: Date = Date()
    var records: [String: DayRecord]
    var game: GameState
}

final class DayStore: ObservableObject {
    @Published var records: [String: DayRecord]
    var enabledOverride: [Tracker]? = nil
    static let key = "dailytrack.records"

    init() {
        if let data = UserDefaults.standard.data(forKey: DayStore.key),
           let decoded = try? JSONDecoder().decode([String: DayRecord].self, from: data) {
            records = decoded
        } else {
            records = [:]
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: DayStore.key)
        }
    }

    func dayKey(_ date: Date) -> String { Fmt.day.string(from: date) }

    func record(_ date: Date) -> DayRecord { records[dayKey(date)] ?? DayRecord() }

    func value(_ id: String, _ date: Date = Date()) -> Int { record(date)[id] }

    func set(_ id: String, _ v: Int, _ date: Date = Date()) {
        var r = record(date)
        r[id] = max(0, v)
        records[dayKey(date)] = r
        save()
    }

    func enabled() -> [Tracker] { enabledOverride ?? ExperimentsManager.shared.enabledTrackers() }

    func enabledDaily(_ date: Date = Date()) -> [Tracker] {
        enabled().filter { $0.schedule == .daily }
    }

    func progress(_ t: Tracker, _ date: Date = Date()) -> Double {
        guard t.target > 0 else { return 0 }
        return min(1, Double(value(t.id, date)) / Double(t.target))
    }

    func score(_ date: Date = Date()) -> Double {
        let list = enabledDaily(date)
        guard !list.isEmpty else { return 0 }
        let sum = list.reduce(0.0) { $0 + progress($1, date) }
        return sum / Double(list.count)
    }

    func isKept(_ date: Date = Date()) -> Bool { score(date) >= 0.75 }

    func isPerfect(_ date: Date = Date()) -> Bool {
        let list = enabledDaily(date)
        guard !list.isEmpty else { return false }
        return list.allSatisfy { progress($0, date) >= 1 }
    }

    func weekDays(_ date: Date = Date()) -> [Date] {
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: date)
        let start = cal.date(byAdding: .day, value: -(weekday - 1), to: date) ?? date
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: start) }
    }

    func weekValue(_ t: Tracker, _ date: Date = Date()) -> Int {
        weekDays(date).reduce(0) { $0 + value(t.id, $1) }
    }

    func weekProgress(_ t: Tracker, _ date: Date = Date()) -> Double {
        guard t.target > 0 else { return 0 }
        return min(1, Double(weekValue(t, date)) / Double(t.target))
    }

    func currentStreak() -> Int {
        let cal = Calendar.current
        var day = Date()
        if !isKept(day) { day = cal.date(byAdding: .day, value: -1, to: day) ?? day }
        var n = 0
        while isKept(day) {
            n += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: day) else { break }
            day = prev
        }
        return n
    }

    func longestStreak() -> Int {
        let cal = Calendar.current
        var best = 0, run = 0
        var day = Date()
        for _ in 0..<4000 {
            if isKept(day) { run += 1; best = max(best, run) } else { run = 0 }
            guard let prev = cal.date(byAdding: .day, value: -1, to: day) else { break }
            day = prev
        }
        return best
    }

    func keptDaysCount() -> Int {
        let list = enabledDaily()
        guard !list.isEmpty else { return 0 }
        return records.keys.filter { k in
            guard Fmt.day.date(from: k) != nil else { return false }
            let rec = records[k] ?? DayRecord()
            let sum = list.reduce(0.0) { acc, t in
                let target = max(1, t.target)
                return acc + min(1, Double(rec[t.id]) / Double(target))
            }
            return sum / Double(list.count) >= 0.75
        }.count
    }

    func scoreSeries(last days: Int) -> [(Date, Double)] {
        let cal = Calendar.current
        return (0..<days).reversed().compactMap { i in
            guard let d = cal.date(byAdding: .day, value: -i, to: Date()) else { return nil }
            return (d, score(d))
        }
    }

    func exportBlob() -> DayBlob {
        DayBlob(records: records, game: Game.shared.state)
    }

    func importBlob(_ blob: DayBlob) {
        records = blob.records
        save()
        Game.shared.replace(blob.game)
    }

    func exportCSV() -> String {
        var rows = ["date,tracker,value,target"]
        let sorted = records.keys.sorted()
        for k in sorted {
            guard let rec = records[k] else { continue }
            for t in Catalog.all where rec.values[t.id] != nil {
                rows.append("\(k),\(t.id),\(rec[t.id]),\(t.target)")
            }
        }
        return rows.joined(separator: "\n")
    }

    func resetAll() {
        records = [:]
        save()
        Game.shared.reset()
    }
}
