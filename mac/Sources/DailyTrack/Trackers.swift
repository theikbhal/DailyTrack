import Foundation

enum Catalog {
    static let all: [Tracker] = [
        Tracker(id: "darood", title: "Darood", detail: "1100 daily", category: .zikir,
                kind: .counter, target: 1100, unit: "counts", schedule: .daily,
                icon: "hands.clap.fill", abacus: true),
        Tracker(id: "astaghfar", title: "Astaghfar", detail: "1100 daily", category: .zikir,
                kind: .counter, target: 1100, unit: "counts", schedule: .daily,
                icon: "arrow.counterclockwise", abacus: true),
        Tracker(id: "teentasbih", title: "Teen Tasbih", detail: "33 x 3 after each prayer", category: .zikir,
                kind: .counter, target: 99, unit: "counts", schedule: .daily,
                icon: "circle.grid.3x3.fill", abacus: true),
        Tracker(id: "nafil20", title: "20 Rakat Nafil", detail: "12 before Zuhr, 4 before Asr, 2 after Maghrib, 2 after Isha",
                category: .namaz, kind: .checklist, target: 20, unit: "rakat", schedule: .daily,
                icon: "moon.stars.fill", abacus: false),
        Tracker(id: "chash", title: "Chash Namaz", detail: "2 rakat after sunrise", category: .namaz,
                kind: .checklist, target: 2, unit: "rakat", schedule: .daily,
                icon: "sunrise.fill", abacus: false),
        Tracker(id: "ishraq", title: "Ishraq Namaz", detail: "2 rakat, ~20 min after sunrise", category: .namaz,
                kind: .checklist, target: 2, unit: "rakat", schedule: .daily,
                icon: "sun.max.fill", abacus: false),
        Tracker(id: "zuhrsunnat", title: "Zuhr Sunnat Ghairullah", detail: "4 rakat, keep 30 minutes free after Zuhr",
                category: .namaz, kind: .checklist, target: 4, unit: "rakat", schedule: .daily,
                icon: "sun.min.fill", abacus: false),
        Tracker(id: "namaz5", title: "5 Daily Prayers", detail: "Fajr, Zuhr, Asr, Maghrib, Isha", category: .namaz,
                kind: .checklist, target: 5, unit: "prayers", schedule: .daily,
                icon: "clock.fill", abacus: false),
        Tracker(id: "nightsleep", title: "Night Sleep", detail: "4 to 5 hours", category: .rest,
                kind: .duration, target: 270, unit: "min", schedule: .daily,
                icon: "bed.double.fill", abacus: false),
        Tracker(id: "morningsleep", title: "Morning Sleep", detail: "4 hours nap window", category: .rest,
                kind: .duration, target: 240, unit: "min", schedule: .daily,
                icon: "cloud.moon.fill", abacus: false),
        Tracker(id: "sundayextra", title: "Sunday Holiday Extra", detail: "More worship and family time on your day off",
                category: .life, kind: .checklist, target: 1, unit: "done", schedule: .weekly,
                icon: "calendar.badge.plus", abacus: false),
        Tracker(id: "ismail", title: "Talk to Ismail Bhai", detail: "Dryfruits call - daily if possible", category: .life,
                kind: .checklist, target: 1, unit: "done", schedule: .daily,
                icon: "phone.fill", abacus: false),
        Tracker(id: "madrasa", title: "Visit Madrasa", detail: "Once or twice a week", category: .life,
                kind: .counter, target: 2, unit: "visits", schedule: .weekly,
                icon: "building.columns.fill", abacus: false)
    ]

    static func tracker(_ id: String) -> Tracker? { all.first { $0.id == id } }

    static let categories: [TrackerCategory] = [.zikir, .namaz, .rest, .life]
}
