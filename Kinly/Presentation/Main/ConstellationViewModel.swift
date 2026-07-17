import Foundation
import Observation

struct ConstellationStar: Identifiable, Hashable {
    let person: Person
    let brightness: Double
    var id: UUID { person.id }
}

@MainActor
@Observable
final class ConstellationViewModel {
    private(set) var stars: [ConstellationStar] = []
    private(set) var isLoading = true
    private(set) var errorMessage: String?
    private(set) var timeline: [Interaction] = []
    private(set) var brightenFeedback: String?
    var selectedPerson: Person?
    var noteDraft = ""
    var markImportant = false
    var conversationStarters: [String] = []
    var showAddPerson = false
    var showAlignGame = false
    var newPersonName = ""
    var newPersonRhythm = 7

    private let dependencies: AppDependencies
    private let brightnessCalculator = StarBrightnessCalculator()

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }

    var reachOutShareText: String {
        guard let person = selectedPerson else { return "" }
        return ReachOutMessageBuilder.body(personName: person.name, rhythmDays: person.contactRhythmDays)
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let people = try await dependencies.personRepository.fetchAll()
            let latest = try await dependencies.interactionRepository.fetchLatestByPerson()
            stars = people.map { person in
                let brightness = brightnessCalculator.brightness(
                    lastInteractionDate: latest[person.id]?.date,
                    rhythmDays: person.contactRhythmDays
                )
                return ConstellationStar(person: person, brightness: brightness)
            }
        } catch {
            errorMessage = "Couldn't load your constellation."
        }
    }

    func select(_ person: Person) {
        selectedPerson = person
        noteDraft = ""
        markImportant = false
        brightenFeedback = nil
        conversationStarters = dependencies.conversationStarterProvider.suggestions()
        Task { await loadTimeline(for: person.id) }
    }

    func dismissDetail() {
        selectedPerson = nil
        timeline = []
        brightenFeedback = nil
    }

    func logContact() async {
        guard let person = selectedPerson else { return }
        do {
            _ = try await dependencies.logInteractionUseCase.execute(
                person: person,
                note: noteDraft.isEmpty ? nil : noteDraft,
                isImportantDate: markImportant
            )
            HapticsService.shared.playStarBrighten()
            brightenFeedback = "Their star brightened — a gentle metaphor for fresh contact, not a score."
            noteDraft = ""
            markImportant = false
            await dependencies.reminderScheduler.scheduleGentleReminder(for: person)
            await loadTimeline(for: person.id)
            await load()

            try? await Task.sleep(for: .seconds(1.6))
            if selectedPerson?.id == person.id {
                dismissDetail()
            }
        } catch {
            errorMessage = "Couldn't save. Please try again."
        }
    }

    func addPerson() async {
        let trimmed = newPersonName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let person = Person(name: trimmed, contactRhythmDays: newPersonRhythm)
        do {
            try await dependencies.personRepository.add(person)
            await dependencies.reminderScheduler.scheduleGentleReminder(for: person)
            newPersonName = ""
            newPersonRhythm = 7
            showAddPerson = false
            await load()
        } catch {
            errorMessage = "Couldn't add this person."
        }
    }

    func deleteSelectedPerson() async {
        guard let person = selectedPerson else { return }
        do {
            try await dependencies.personRepository.delete(byID: person.id)
            await dependencies.reminderScheduler.cancelReminder(for: person.id)
            dismissDetail()
            await load()
        } catch {
            errorMessage = "Couldn't remove them."
        }
    }

    private func loadTimeline(for personID: UUID) async {
        do {
            timeline = try await dependencies.interactionRepository.fetchAll(forPersonID: personID)
        } catch {
            timeline = []
        }
    }
}
