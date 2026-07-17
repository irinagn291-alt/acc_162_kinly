import Foundation

/// Persistence port for `Person` entities.
protocol PersonRepository {
    func fetchAll() async throws -> [Person]
    func fetch(byID id: UUID) async throws -> Person?
    func add(_ person: Person) async throws
    func update(_ person: Person) async throws
    func delete(byID id: UUID) async throws
    func deleteAll() async throws
}
