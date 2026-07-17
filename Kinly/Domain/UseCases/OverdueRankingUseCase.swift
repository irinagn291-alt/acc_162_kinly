import Foundation

/// A person ranked by how overdue contact with them is, for the dashboard.
struct OverdueRanking: Identifiable, Sendable {
    let person: Person
    let lastInteractionDate: Date?
    let overdueRatio: Double

    var id: UUID { person.id }
}

/// Lists every person sorted by how overdue contact is, most overdue first.
struct OverdueRankingUseCase {
    private let personRepository: PersonRepository
    private let interactionRepository: InteractionRepository
    private let calculator: StarBrightnessCalculator

    init(
        personRepository: PersonRepository,
        interactionRepository: InteractionRepository,
        calculator: StarBrightnessCalculator = StarBrightnessCalculator()
    ) {
        self.personRepository = personRepository
        self.interactionRepository = interactionRepository
        self.calculator = calculator
    }

    func execute(now: Date = .now) async throws -> [OverdueRanking] {
        let people = try await personRepository.fetchAll()
        let latestByPerson = try await interactionRepository.fetchLatestByPerson()

        return people
            .map { person in
                let lastDate = latestByPerson[person.id]?.date
                let ratio = calculator.overdueRatio(lastInteractionDate: lastDate, rhythmDays: person.contactRhythmDays, now: now)
                return OverdueRanking(person: person, lastInteractionDate: lastDate, overdueRatio: ratio)
            }
            .sorted { $0.overdueRatio > $1.overdueRatio }
    }
}
