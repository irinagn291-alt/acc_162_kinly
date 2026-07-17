import Foundation

/// Persistence port for `Interaction` entities.
protocol InteractionRepository {
    func fetchAll(forPersonID personID: UUID) async throws -> [Interaction]
    func fetchLatest(forPersonID personID: UUID) async throws -> Interaction?
    /// Most recent interaction per person, keyed by person id.
    func fetchLatestByPerson() async throws -> [UUID: Interaction]
    func add(_ interaction: Interaction) async throws
    func deleteAll() async throws
}
