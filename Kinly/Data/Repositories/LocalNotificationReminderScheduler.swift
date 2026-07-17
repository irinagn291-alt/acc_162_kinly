import Foundation
import UserNotifications

/// Schedules gentle local-only "reach out" reminders. Never uses push notifications.
final class LocalNotificationReminderScheduler: ReminderScheduler {
    private let center = UNUserNotificationCenter.current()

    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound])
        } catch {
            return false
        }
    }

    func currentAuthorizationStatus() async -> Bool {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus == .authorized
    }

    func scheduleGentleReminder(for person: Person) async {
        let identifier = reminderIdentifier(for: person.id)
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        let content = UNMutableNotificationContent()
        content.title = "Time to connect"
        content.body = ReachOutMessageBuilder.body(personName: person.name, rhythmDays: person.contactRhythmDays)
        content.sound = .default

        let seconds = max(60, Double(person.contactRhythmDays) * 86_400)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        do {
            try await center.add(request)
        } catch {
            // Reminders are best-effort; Kinly stays fully usable without them.
        }
    }

    func cancelReminder(for personID: UUID) async {
        center.removePendingNotificationRequests(withIdentifiers: [reminderIdentifier(for: personID)])
    }

    func cancelAll() async {
        center.removeAllPendingNotificationRequests()
    }

    private func reminderIdentifier(for personID: UUID) -> String {
        "kinly.reach-out.\(personID.uuidString)"
    }
}
