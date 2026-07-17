import Foundation

@MainActor
@Observable
final class OnboardingViewModel {
    struct DraftPerson: Identifiable, Hashable {
        let id = UUID()
        var name: String
        var rhythmDays: Int = 7
    }

    enum NotificationRequestStatus {
        case notAsked
        case granted
        case denied
    }

    private let dependencies: AppDependencies

    let stepTitles = [
        "Who are your people?",
        "How often to stay in touch?",
        "Gentle reminders",
        "Your constellation"
    ]

    var step = 0
    var draftPeople: [DraftPerson] = []
    var newPersonName = ""
    var notificationStatus: NotificationRequestStatus = .notAsked
    var isSaving = false
    var errorMessage: String?

    var canAddMorePeople: Bool { draftPeople.count < 3 }
    var canGoToRhythmStep: Bool { !draftPeople.isEmpty }

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }

    func addDraftPerson() {
        addDraftPerson(named: newPersonName)
        newPersonName = ""
    }

    func addDraftPerson(named name: String) {
        guard canAddMorePeople else { return }
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !draftPeople.contains(where: { $0.name == trimmed }) else { return }
        draftPeople.append(DraftPerson(name: trimmed))
    }

    func removeDraftPerson(_ person: DraftPerson) {
        draftPeople.removeAll { $0.id == person.id }
    }

    func updateRhythm(for personID: DraftPerson.ID, days: Int) {
        guard let index = draftPeople.firstIndex(where: { $0.id == personID }) else { return }
        draftPeople[index].rhythmDays = days
    }

    func goNext() {
        step = min(step + 1, stepTitles.count - 1)
    }

    func goBack() {
        step = max(step - 1, 0)
    }

    func requestNotifications() async {
        let granted = await dependencies.reminderScheduler.requestAuthorization()
        notificationStatus = granted ? .granted : .denied
        goNext()
    }

    @discardableResult
    func finishOnboarding() async -> Bool {
        isSaving = true
        defer { isSaving = false }

        do {
            for draft in draftPeople {
                let person = Person(name: draft.name, contactRhythmDays: draft.rhythmDays)
                try await dependencies.personRepository.add(person)
                if notificationStatus == .granted {
                    await dependencies.reminderScheduler.scheduleGentleReminder(for: person)
                }
            }
            return true
        } catch {
            errorMessage = "Couldn't save. Please try again."
            return false
        }
    }
}
