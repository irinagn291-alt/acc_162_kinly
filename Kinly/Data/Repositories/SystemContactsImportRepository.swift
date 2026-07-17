import Contacts
import Foundation

/// Concrete, explicit opt-in adapter over the `Contacts` framework.
/// Only ever invoked from a user-initiated "import from contacts" action —
/// Kinly never reads contacts in the background or without this explicit ask.
final class SystemContactsImportRepository: ContactsImportRepository {
    func requestAccess() async -> ContactsAccessStatus {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        switch status {
        case .authorized, .limited:
            return .authorized
        case .notDetermined:
            return await requestFreshAccess()
        case .denied, .restricted:
            return .denied
        @unknown default:
            return .denied
        }
    }

    func fetchImportableContacts() async throws -> [ImportableContact] {
        let store = CNContactStore()
        let keys: [CNKeyDescriptor] = [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor
        ]
        let request = CNContactFetchRequest(keysToFetch: keys)

        var contacts: [ImportableContact] = []
        try store.enumerateContacts(with: request) { contact, _ in
            let fullName = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces)
            guard !fullName.isEmpty else { return }
            contacts.append(ImportableContact(id: contact.identifier, name: fullName))
        }
        return contacts.sorted { $0.name < $1.name }
    }

    private func requestFreshAccess() async -> ContactsAccessStatus {
        let store = CNContactStore()
        do {
            let granted = try await store.requestAccess(for: .contacts)
            return granted ? .authorized : .denied
        } catch {
            return .denied
        }
    }
}
