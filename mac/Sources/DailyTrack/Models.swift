import Foundation

enum TrackerCategory: String, Codable, CaseIterable, Identifiable {
    case zikir, namaz, rest, life
    var id: String { rawValue }
    var label: String {
        switch self {
        case .zikir: return "Zikir"
        case .namaz: return "Namaz"
        case .rest: return "Rest"
        case .life: return "Life"
        }
    }
}

enum TrackerKind: String, Codable {
    case counter, checklist, duration
}

enum TrackerSchedule: String, Codable {
    case daily, weekly
}

struct Tracker: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let detail: String
    let category: TrackerCategory
    let kind: TrackerKind
    let target: Int
    let unit: String
    let schedule: TrackerSchedule
    let icon: String
    let abacus: Bool
}

struct DayRecord: Codable, Equatable {
    var values: [String: Int] = [:]
    subscript(id: String) -> Int {
        get { values[id] ?? 0 }
        set { values[id] = newValue }
    }
}

struct LevelInfo: Equatable {
    let level: Int
    let name: String
    let start: Int
    let next: Int
}

enum Levels {
    static let thresholds = [0, 200, 500, 1000, 2000, 3500, 6000, 10000]
    static let names = [
        "Newcomer", "Consistent", "Steady", "Devoted",
        "Disciplined", "Focused", "Master", "Legend"
    ]

    static func at(_ xp: Int) -> LevelInfo {
        var idx = 0
        for (i, t) in thresholds.enumerated() where xp >= t { idx = i }
        let start = thresholds[idx]
        let next = idx + 1 < thresholds.count ? thresholds[idx + 1] : thresholds[idx]
        return LevelInfo(level: idx + 1, name: names[idx], start: start, next: next)
    }

    static func progress(_ xp: Int) -> Double {
        let info = at(xp)
        guard info.next > info.start else { return 1 }
        return Double(xp - info.start) / Double(info.next - info.start)
    }
}

enum Fmt {
    static let day: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    static let long: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    static let hhmm: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .none
        f.timeStyle = .short
        return f
    }()
}
