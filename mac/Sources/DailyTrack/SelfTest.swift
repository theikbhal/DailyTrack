import Foundation

enum SelfTest {
    static func planText() -> String {
        let s = AppSettings.shared
        var lines = ["DailyTrack notification plan:"]
        if s.morningOn { lines.append("  daily \(s.morningHour):00 morning nudge (repeating)") }
        if s.middayOn { lines.append("  daily \(s.middayHour):30 midday nudge (repeating)") }
        if s.eveningOn { lines.append("  daily \(s.eveningHour):00 evening review (repeating)") }
        lines.append("  live: one-shot on every tracker completion")
        lines.append("  enabled flag experiment 'notifications' = \(ExperimentsManager.shared.isEnabled("notifications"))")
        return lines.joined(separator: "\n")
    }

    @discardableResult
    static func run() -> Int32 {
        var failed = 0
        func expect(_ cond: Bool, _ msg: String) {
            if cond { print("ok   - \(msg)") }
            else { print("FAIL - \(msg)"); failed += 1 }
        }

        expect(Catalog.all.count == 13, "catalog has 13 trackers")
        expect(Set(Catalog.all.map(\.id)).count == Catalog.all.count, "tracker ids unique")
        expect(Catalog.all.allSatisfy { $0.target > 0 }, "all targets positive")
        expect(Catalog.all.allSatisfy { !$0.title.isEmpty && !$0.icon.isEmpty }, "titles and icons present")
        expect(Catalog.tracker("darood")?.target == 1100, "darood target 1100")
        expect(Catalog.tracker("astaghfar")?.target == 1100, "astaghfar target 1100")
        expect(Catalog.tracker("nightsleep")?.target == 270, "night sleep 4h30m target")

        let store = DayStore()
        store.records = [:]
        let cal = Calendar.current
        let today = Date()
        let yesterday = cal.date(byAdding: .day, value: -1, to: today)!

        expect(store.score() == 0, "empty day scores 0")
        expect(!store.isKept(), "empty day is not kept")
        expect(store.weekDays().count == 7, "week has 7 days")

        var perfect: [String: Int] = [
            "darood": 1100, "astaghfar": 1100, "teentasbih": 99, "nafil20": 20,
            "chash": 2, "ishraq": 2, "zuhrsunnat": 4, "namaz5": 5,
            "nightsleep": 270, "morningsleep": 240, "ismail": 1
        ]
        store.records[store.dayKey(today)] = DayRecord(values: perfect)
        expect(abs(store.score() - 1) < 0.001, "full day scores 100 percent")
        expect(store.isKept(), "full day is kept")

        perfect["darood"] = 550
        store.records[store.dayKey(yesterday)] = DayRecord(values: perfect)
        var partial = [String: Int]()
        for t in Catalog.all where t.schedule == .daily { partial[t.id] = 0 }
        partial["darood"] = 825
        store.records[store.dayKey(cal.date(byAdding: .day, value: -2, to: today)!)] = DayRecord(values: partial)
        let partialScore = store.score(cal.date(byAdding: .day, value: -2, to: today)!)
        expect(partialScore < 0.75, "one-tracker day is below the kept line")
        expect(store.currentStreak() == 2, "streak counts today and yesterday")

        expect(Levels.at(0).level == 1, "level 1 at 0 XP")
        expect(Levels.at(199).level == 1, "level 1 below 200 XP")
        expect(Levels.at(200).level == 2, "level 2 at 200 XP")
        expect(Levels.at(1999).level == 4, "level 4 below 2000 XP")
        expect(Levels.at(2000).level == 5, "level 5 at 2000 XP")
        expect(Levels.at(100000).level == 8, "max level 8")
        expect(Levels.progress(500) >= 0 && Levels.progress(500) <= 1, "level progress in range")

        let csv = store.exportCSV()
        expect(csv.hasPrefix("date,tracker,value,target"), "csv header")
        expect(csv.contains("darood"), "csv contains darood rows")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let blob = store.exportBlob()
        if let data = try? encoder.encode(blob) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let back = try? decoder.decode(DayBlob.self, from: data) {
                expect(back.records.keys.sorted() == blob.records.keys.sorted(), "export/import roundtrip keys")
            } else {
                expect(false, "export blob decodes")
            }
        } else {
            expect(false, "export blob encodes")
        }

        expect(Game.badgeDefs().count == 16, "16 badge definitions")
        expect(Set(Game.badgeDefs().map(\.id)).count == Game.badgeDefs().count, "badge ids unique")

        let exp = ExperimentsManager()
        expect(exp.trackerExperiments.count == 13, "one experiment flag per tracker")
        expect(exp.features.contains { $0.id == "abacus" }, "abacus flag exists")
        expect(exp.features.contains { $0.id == "notifications" }, "notifications flag exists")
        expect(exp.features.contains { $0.id == "tursoSync" }, "turso stub flag exists")

        expect(AppTheme.allCases.count == 8, "8 themes including dark")

        print(failed == 0 ? "\nALL TESTS PASSED" : "\n\(failed) TEST(S) FAILED")
        return failed == 0 ? 0 : 1
    }
}
