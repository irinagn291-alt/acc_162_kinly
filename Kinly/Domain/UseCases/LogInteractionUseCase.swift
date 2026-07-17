import Foundation

/// Records a new interaction and reports the resulting star brightness —
/// the "moment of outcome" that follows logging a moment of contact.
struct LogInteractionUseCase {
    private let interactionRepository: InteractionRepository
    private let brightnessCalculator: StarBrightnessCalculator

    init(
        interactionRepository: InteractionRepository,
        brightnessCalculator: StarBrightnessCalculator = StarBrightnessCalculator()
    ) {
        self.interactionRepository = interactionRepository
        self.brightnessCalculator = brightnessCalculator
    }

    @discardableResult
    func execute(person: Person, note: String?, isImportantDate: Bool, now: Date = .now) async throws -> Double {
        let interaction = Interaction(personID: person.id, date: now, note: note, isImportantDate: isImportantDate)
        try await interactionRepository.add(interaction)
        return brightnessCalculator.brightness(lastInteractionDate: now, rhythmDays: person.contactRhythmDays, now: now)
    }
}
