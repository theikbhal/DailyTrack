import Foundation
import Combine

struct GameState: Codable {
    var xp = 0
    var lifetimeXP = 0
    var coins = 0
    var energy = 10
    var maxEnergy = 10
    var lastRefill = Date()
    var bosses: [String: Double] = ["laziness": 100, "weakHealth": 100]
    var bossWins: [String: Int] = [:]
    var badges: [String] = []
    var totalCounts = 0
    var keptAwarded: [String] = []
    var lastChecked: String = ""
}

struct BadgeDef {
    let id: String
    let title: String
    let icon: String
    let desc: String
    let check: (DayStore, GameState) -> Bool
}

struct BossInfo: Identifiable {
    let id: String
    let title: String
    let icon: String
    let hp: Double
    let max: Double
    let wins: Int
}

final class Game: ObservableObject {
    static let shared = Game()
    @Published var state: GameState
    private let saveKey = "dailytrack.game"

    private init() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode(GameState.self, from: data) {
            state = decoded
        } else {
            state = GameState()
        }
        refillTick()
    }

    func save() {
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    func replace(_ s: GameState) {
        state = s
        save()
    }

    func reset() {
        state = GameState()
        save()
    }

    var level: LevelInfo { Levels.at(state.xp) }

    func refillTick() {
        let interval: TimeInterval = 30 * 60
        let now = Date()
        let gained = Int(now.timeIntervalSince(state.lastRefill) / interval)
        if gained > 0 {
            state.energy = min(state.maxEnergy, state.energy + gained)
            state.lastRefill = state.lastRefill.addingTimeInterval(Double(gained) * interval)
            save()
        }
    }

    func addXP(_ n: Int) {
        let before = level.level
        state.xp += n
        state.lifetimeXP += n
        let after = Levels.at(state.xp)
        if after.level > before {
            state.maxEnergy = 10 + (after.level - 1) * 2
            state.energy = state.maxEnergy
        }
        save()
    }

    func addCoins(_ n: Int) {
        state.coins += n
        save()
    }

    @discardableResult
    func spendCoins(_ n: Int) -> Bool {
        guard state.coins >= n else { return false }
        state.coins -= n
        save()
        return true
    }

    func buyEnergy() -> Bool {
        guard spendCoins(30) else { return false }
        state.energy = state.maxEnergy
        save()
        return true
    }

    @discardableResult
    func pushThrough() -> Bool {
        refillTick()
        guard state.energy >= 2 else { return false }
        state.energy -= 2
        addXP(25)
        addCoins(5)
        return true
    }

    private func damage(_ boss: String, _ amount: Double) {
        var hp = state.bosses[boss] ?? 0
        hp = max(0, hp - amount)
        state.bosses[boss] = hp
        if hp <= 0 {
            state.bossWins[boss, default: 0] += 1
            let levelScale = 1.0 + Double(level.level) * 0.25
            state.bosses[boss] = 100 * levelScale
            addXP(100)
            addCoins(50)
        }
        save()
    }

    private func heal(_ boss: String, _ amount: Double) {
        let maxHP = 100 * (1.0 + Double(level.level) * 0.25)
        state.bosses[boss] = min(maxHP, (state.bosses[boss] ?? 0) + amount)
        save()
    }

    func valueChanged(t: Tracker, old: Int, new: Int) {
        guard new > old else { return }
        if t.kind == .counter {
            state.totalCounts += (new - old)
        }
        if old < t.target && new >= t.target {
            addXP(20)
            addCoins(5)
            if t.category == .zikir { damage("laziness", 8) }
            if t.category == .rest { damage("weakHealth", 8) }
        }
        save()
    }

    func reconcile(store: DayStore) {
        let today = store.dayKey(Date())
        if !state.lastChecked.isEmpty && state.lastChecked != today {
            if let prev = Fmt.day.date(from: state.lastChecked), !store.isKept(prev) {
                heal("laziness", 15)
                heal("weakHealth", 15)
            }
        }
        state.lastChecked = today
        if store.isKept() && !state.keptAwarded.contains(today) {
            state.keptAwarded.append(today)
            addXP(50)
            addCoins(25)
            damage("laziness", 20)
            damage("weakHealth", 20)
        }
        refreshBadges(store: store)
        save()
    }

    func bosses(store: DayStore) -> [BossInfo] {
        let defs = [
            ("laziness", "Laziness", "zzz"),
            ("weakHealth", "Weak Health", "heart.slash")
        ]
        return defs.map {
            BossInfo(id: $0.0, title: $0.1, icon: $0.2,
                     hp: state.bosses[$0.0] ?? 0,
                     max: 100 * (1.0 + Double(level.level) * 0.25),
                     wins: state.bossWins[$0.0] ?? 0)
        }
    }

    static func badgeDefs() -> [BadgeDef] {
        [
            BadgeDef(id: "firstStep", title: "First Step", icon: "footprints",
                     desc: "Log any tracker once") { s, g in g.totalCounts > 0 || !s.records.isEmpty },
            BadgeDef(id: "darood1100", title: "Darood 1100", icon: "hands.clap.fill",
                     desc: "Reach 1100 darood in a day") { s, _ in
                s.records.values.contains { ($0.values["darood"] ?? 0) >= 1100 } },
            BadgeDef(id: "astaghfar1100", title: "Astaghfar 1100", icon: "arrow.counterclockwise",
                     desc: "Reach 1100 astaghfar in a day") { s, _ in
                s.records.values.contains { ($0.values["astaghfar"] ?? 0) >= 1100 } },
            BadgeDef(id: "teenTasbih", title: "Teen Tasbih", icon: "circle.grid.3x3.fill",
                     desc: "Complete 99 teen tasbih in a day") { s, _ in
                s.records.values.contains { ($0.values["teentasbih"] ?? 0) >= 99 } },
            BadgeDef(id: "nafil20", title: "20 Rakat Nafil", icon: "moon.stars.fill",
                     desc: "Finish all 20 nafil rakat") { s, _ in
                s.records.values.contains { ($0.values["nafil20"] ?? 0) >= 20 } },
            BadgeDef(id: "fivePrayers", title: "Five Prayers", icon: "clock.fill",
                     desc: "Pray all 5 daily prayers") { s, _ in
                s.records.values.contains { ($0.values["namaz5"] ?? 0) >= 5 } },
            BadgeDef(id: "ishraq", title: "Ishraq", icon: "sun.max.fill",
                     desc: "Offer Ishraq twice in a day") { s, _ in
                s.records.values.contains { ($0.values["ishraq"] ?? 0) >= 2 } },
            BadgeDef(id: "zuhrSunnat", title: "Zuhr Sunnat", icon: "sun.min.fill",
                     desc: "Complete the Zuhr sunnat ghairullah") { s, _ in
                s.records.values.contains { ($0.values["zuhrsunnat"] ?? 0) >= 4 } },
            BadgeDef(id: "streak7", title: "7 Day Streak", icon: "flame.fill",
                     desc: "Keep 7 days in a row") { s, _ in s.currentStreak() >= 7 },
            BadgeDef(id: "streak30", title: "30 Day Streak", icon: "bolt.fill",
                     desc: "Keep 30 days in a row") { s, _ in s.currentStreak() >= 30 },
            BadgeDef(id: "perfectDay", title: "Perfect Day", icon: "star.fill",
                     desc: "Every enabled tracker at 100 percent") { s, _ in
                s.records.keys.contains { k in
                    guard let d = Fmt.day.date(from: k) else { return false }
                    return s.isPerfect(d)
                } },
            BadgeDef(id: "sunday", title: "Sunday Extra", icon: "calendar.badge.plus",
                     desc: "Use a Sunday for extra worship") { s, _ in
                s.records.values.contains { ($0.values["sundayextra"] ?? 0) >= 1 } },
            BadgeDef(id: "madrasa", title: "Madrasa Week", icon: "building.columns.fill",
                     desc: "Visit the madrasa twice in a week") { s, _ in
                s.records.values.reduce(0) { $0 + ($1.values["madrasa"] ?? 0) } >= 2 },
            BadgeDef(id: "ismail7", title: "Ismail Call", icon: "phone.fill",
                     desc: "Call Ismail bhai on 7 different days") { s, _ in
                s.records.values.filter { ($0.values["ismail"] ?? 0) >= 1 }.count >= 7 },
            BadgeDef(id: "level5", title: "Level 5", icon: "crown.fill",
                     desc: "Reach the Disciplined level") { _, g in Levels.at(g.xp).level >= 5 },
            BadgeDef(id: "bossDown", title: "Boss Down", icon: "figure.martial.art",
                     desc: "Defeat an enemy once") { _, g in g.bossWins.values.reduce(0, +) >= 1 }
        ]
    }

    func refreshBadges(store: DayStore) {
        var newly: [String] = []
        for def in Game.badgeDefs() where !state.badges.contains(def.id) {
            if def.check(store, state) {
                state.badges.append(def.id)
                newly.append(def.id)
            }
        }
        if !newly.isEmpty {
            addXP(30)
            addCoins(15)
            save()
        }
    }

    func unlockedBadges() -> [BadgeDef] {
        Game.badgeDefs().filter { state.badges.contains($0.id) }
    }

    func lockedBadges() -> [BadgeDef] {
        Game.badgeDefs().filter { !state.badges.contains($0.id) }
    }
}
