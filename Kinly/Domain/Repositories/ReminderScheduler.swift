import Foundation

/// Port for scheduling gentle, local-only "reach out" reminders.
protocol ReminderScheduler {
    func requestAuthorization() async -> Bool
    func currentAuthorizationStatus() async -> Bool
    func scheduleGentleReminder(for person: Person) async
    func cancelReminder(for personID: UUID) async
    func cancelAll() async
}
