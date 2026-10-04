import Foundation
import Combine

struct Experiment: Identifiable {
    let id: String
    let name: String
    let description: String
    let defaultEnabled: Bool
    let isTracker: Bool
}

final class ExperimentsManager: ObservableObject {
    @Published var values: [String: Bool] = [:]
    static let shared = ExperimentsManager()
    private let saveKey = "dailytrack.experiments"

    let features: [Experiment] = [
        Experiment(id: "onboarding", name: "Onboarding", description: "Welcome tour on first launch",
                   defaultEnabled: true, isTracker: false),
        Experiment(id: "abacus", name: "Abacus Counter", description: "Bead board for zikir counters",
                   defaultEnabled: true, isTracker: false),
        Experiment(id: "calendar", name: "Calendar View", description: "Day, week, month and year history",
                   defaultEnabled: true, isTracker: false),
        Experiment(id: "encourage", name: "Encourage", description: "Motivation tab with a push-through boost",
                   defaultEnabled: true, isTracker: false),
        Experiment(id: "enemies", name: "Enemies", description: "Laziness and weak-health boss bars",
                   defaultEnabled: true, isTracker: false),
        Experiment(id: "rewards", name: "Rewards", description: "Levels, badges, coins and energy",
                   defaultEnabled: true, isTracker: false),
        Experiment(id: "confetti", name: "Confetti", description: "Celebration animation on big wins",
                   defaultEnabled: true, isTracker: false),
        Experiment(id: "notifications", name: "Daily Push Notifications", description: "Morning, midday and evening nudges",
                   defaultEnabled: true, isTracker: false),
        Experiment(id: "tursoSync", name: "Turso Cloud Sync", description: "Experimental sync stub, local data stays primary",
                   defaultEnabled: false, isTracker: false)
    ]

    var trackerExperiments: [Experiment] {
        Catalog.all.map {
            Experiment(id: $0.id, name: $0.title, description: $0.detail + " (\($0.target) \($0.unit))",
                       defaultEnabled: true, isTracker: true)
        }
    }

    var all: [Experiment] { features + trackerExperiments }

    static let sharedInit: Void = { _ = ExperimentsManager.shared }()

    init() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([String: Bool].self, from: data) {
            values = decoded
        }
    }

    func isEnabled(_ id: String) -> Bool {
        if let v = values[id] { return v }
        return all.first { $0.id == id }?.defaultEnabled ?? false
    }

    func toggle(_ id: String) {
        values[id] = !isEnabled(id)
        save()
    }

    func set(_ id: String, _ on: Bool) {
        values[id] = on
        save()
    }

    func resetAll() {
        values = [:]
        save()
    }

    func enabledTrackers() -> [Tracker] {
        Catalog.all.filter { isEnabled($0.id) }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(values) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }
}
