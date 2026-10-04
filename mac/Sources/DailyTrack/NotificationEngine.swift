import Foundation
import UserNotifications

final class NotificationEngine: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationEngine()
    private let center = UNUserNotificationCenter.current()

    override init() {
        super.init()
        center.delegate = self
    }

    func requestPermission() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func authorizationStatus(completion: @escaping (String) -> Void) {
        center.getNotificationSettings { settings in
            let text: String
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral: text = "Allowed"
            case .denied: text = "Blocked - enable in System Settings"
            default: text = "Not requested yet"
            }
            completion(text)
        }
    }

    func reschedule(_ s: AppSettings) {
        guard ExperimentsManager.shared.isEnabled("notifications") else {
            cancelAll()
            return
        }
        center.removeAllPendingNotificationRequests()
        if s.morningOn {
            addRepeating(id: "dailytrack.morning", hour: s.morningHour, minute: 0,
                         title: "Bismillah - start your day",
                         body: "Darood 1100, astaghfar 1100 and your first namaz are waiting. Open DailyTrack.")
        }
        if s.middayOn {
            addRepeating(id: "dailytrack.midday", hour: s.middayHour, minute: 30,
                         title: "Midday check",
                         body: "Zuhr sunnat, nafil rakat and the teen tasbih - a small window now saves the evening.")
        }
        if s.eveningOn {
            addRepeating(id: "dailytrack.evening", hour: s.eveningHour, minute: 0,
                         title: "Evening review",
                         body: "Close the gaps before Isha. Every count you add now keeps your streak alive.")
        }
    }

    private func addRepeating(id: String, hour: Int, minute: Int, title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        var comps = DateComponents()
        comps.hour = hour
        comps.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }

    func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }

    func sendLive(id: String, title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }

    func sendTest() {
        sendLive(id: "dailytrack.test.\(Date().timeIntervalSince1970)",
                 title: "DailyTrack test",
                 body: "Notifications are working. See you at the next reminder.")
    }

    func summary(store: DayStore) -> String {
        let pct = Int(store.score() * 100)
        let remaining = store.enabledDaily().filter { store.progress($0) < 1 }
        if remaining.isEmpty { return "Perfect day - every tracker is complete." }
        let top = remaining.sorted { store.progress($0) < store.progress($1) }.prefix(2)
        let names = top.map { $0.title }.joined(separator: ", ")
        return "Day at \(pct)%. Still open: \(names)."
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
