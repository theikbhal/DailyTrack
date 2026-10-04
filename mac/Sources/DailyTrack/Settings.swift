import Foundation
import Combine

enum Pref {
    static let theme = "dailytrack.theme"
    static let onboardingDone = "dailytrack.onboardingDone"
    static let name = "dailytrack.name"
    static let morningOn = "dailytrack.morningOn"
    static let morningHour = "dailytrack.morningHour"
    static let middayOn = "dailytrack.middayOn"
    static let middayHour = "dailytrack.middayHour"
    static let eveningOn = "dailytrack.eveningOn"
    static let eveningHour = "dailytrack.eveningHour"
    static let tursoURL = "dailytrack.tursoURL"
    static let tursoToken = "dailytrack.tursoToken"
}

final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @Published var themeRaw: String { didSet { UserDefaults.standard.set(themeRaw, forKey: Pref.theme) } }
    @Published var name: String { didSet { UserDefaults.standard.set(name, forKey: Pref.name) } }
    @Published var morningOn: Bool { didSet { UserDefaults.standard.set(morningOn, forKey: Pref.morningOn); NotificationEngine.shared.reschedule(self) } }
    @Published var morningHour: Int { didSet { UserDefaults.standard.set(morningHour, forKey: Pref.morningHour); NotificationEngine.shared.reschedule(self) } }
    @Published var middayOn: Bool { didSet { UserDefaults.standard.set(middayOn, forKey: Pref.middayOn); NotificationEngine.shared.reschedule(self) } }
    @Published var middayHour: Int { didSet { UserDefaults.standard.set(middayHour, forKey: Pref.middayHour); NotificationEngine.shared.reschedule(self) } }
    @Published var eveningOn: Bool { didSet { UserDefaults.standard.set(eveningOn, forKey: Pref.eveningOn); NotificationEngine.shared.reschedule(self) } }
    @Published var eveningHour: Int { didSet { UserDefaults.standard.set(eveningHour, forKey: Pref.eveningHour); NotificationEngine.shared.reschedule(self) } }
    @Published var tursoURL: String { didSet { UserDefaults.standard.set(tursoURL, forKey: Pref.tursoURL) } }
    @Published var tursoToken: String { didSet { UserDefaults.standard.set(tursoToken, forKey: Pref.tursoToken) } }

    private init() {
        let d = UserDefaults.standard
        themeRaw = d.string(forKey: Pref.theme) ?? "system"
        name = d.string(forKey: Pref.name) ?? ""
        morningOn = d.object(forKey: Pref.morningOn) as? Bool ?? true
        morningHour = d.object(forKey: Pref.morningHour) as? Int ?? 6
        middayOn = d.object(forKey: Pref.middayOn) as? Bool ?? true
        middayHour = d.object(forKey: Pref.middayHour) as? Int ?? 13
        eveningOn = d.object(forKey: Pref.eveningOn) as? Bool ?? true
        eveningHour = d.object(forKey: Pref.eveningHour) as? Int ?? 20
        tursoURL = d.string(forKey: Pref.tursoURL) ?? ""
        tursoToken = d.string(forKey: Pref.tursoToken) ?? ""
    }

    var onboardingDone: Bool {
        get { UserDefaults.standard.bool(forKey: Pref.onboardingDone) }
        set { UserDefaults.standard.set(newValue, forKey: Pref.onboardingDone) }
    }

    var syncConfigured: Bool { !tursoURL.isEmpty && !tursoToken.isEmpty }
}
