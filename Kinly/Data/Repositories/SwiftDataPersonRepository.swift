import Foundation
import SwiftData

@MainActor
final class SwiftDataPersonRepository: PersonRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() async throws -> [Person] {
        let descriptor = FetchDescriptor<PersonModel>(sortBy: [SortDescriptor(\.createdAt)])
        return try modelContext.fetch(descriptor).map(Person.init)
    }

    func fetch(byID id: UUID) async throws -> Person? {
        try fetchModel(byID: id).map(Person.init)
    }

    func add(_ person: Person) async throws {
        let model = PersonModel(
            id: person.id,
            name: person.name,
            photoData: person.photoData,
            contactRhythmDays: person.contactRhythmDays,
            createdAt: person.createdAt
        )
        modelContext.insert(model)
        try modelContext.save()
    }

    func update(_ person: Person) async throws {
        guard let model = try fetchModel(byID: person.id) else { return }
        model.name = person.name
        model.photoData = person.photoData
        model.contactRhythmDays = person.contactRhythmDays
        try modelContext.save()
    }

    func delete(byID id: UUID) async throws {
        guard let model = try fetchModel(byID: id) else { return }
        modelContext.delete(model)
        try modelContext.save()
    }

    func deleteAll() async throws {
        try modelContext.delete(model: PersonModel.self)
        try modelContext.save()
    }

    private func fetchModel(byID id: UUID) throws -> PersonModel? {
        var descriptor = FetchDescriptor<PersonModel>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }
}
