import Foundation

/// A contact the user could optionally import as a `Person`.
struct ImportableContact: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
}

enum ContactsAccessStatus: Sendable {
    case authorized
    case denied
}

/// Optional adapter port for importing close people from the system address book.
/// Manual entry must always work without any conforming implementation being used.
protocol ContactsImportRepository {
    func requestAccess() async -> ContactsAccessStatus
    func fetchImportableContacts() async throws -> [ImportableContact]
}
