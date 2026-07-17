import Foundation
import SwiftData

enum InteractionRepositoryError: Error {
    case personNotFound
}

@MainActor
final class SwiftDataInteractionRepository: InteractionRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll(forPersonID personID: UUID) async throws -> [Interaction] {
        let descriptor = FetchDescriptor<InteractionModel>(
            predicate: #Predicate { $0.person?.id == personID },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try modelContext.fetch(descriptor).map(Interaction.init)
    }

    func fetchLatest(forPersonID personID: UUID) async throws -> Interaction? {
        var descriptor = FetchDescriptor<InteractionModel>(
            predicate: #Predicate { $0.person?.id == personID },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first.map(Interaction.init)
    }

    func fetchLatestByPerson() async throws -> [UUID: Interaction] {
        let descriptor = FetchDescriptor<InteractionModel>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        let all = try modelContext.fetch(descriptor)

        var result: [UUID: Interaction] = [:]
        for model in all {
            guard let personID = model.person?.id, result[personID] == nil else { continue }
            result[personID] = Interaction(model)
        }
        return result
    }

    func add(_ interaction: Interaction) async throws {
        let personID = interaction.personID
        var personDescriptor = FetchDescriptor<PersonModel>(predicate: #Predicate { $0.id == personID })
        personDescriptor.fetchLimit = 1

        guard let personModel = try modelContext.fetch(personDescriptor).first else {
            throw InteractionRepositoryError.personNotFound
        }

        let model = InteractionModel(
            id: interaction.id,
            date: interaction.date,
            note: interaction.note,
            isImportantDate: interaction.isImportantDate,
            person: personModel
        )
        modelContext.insert(model)
        try modelContext.save()
    }

    func deleteAll() async throws {
        try modelContext.delete(model: InteractionModel.self)
        try modelContext.save()
    }
}
