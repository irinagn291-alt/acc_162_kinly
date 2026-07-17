import Foundation

/// A logged moment of contact with a `Person`, optionally marking an important date.
struct Interaction: Identifiable, Hashable, Sendable {
    let id: UUID
    var personID: UUID
    var date: Date
    var note: String?
    var isImportantDate: Bool

    init(
        id: UUID = UUID(),
        personID: UUID,
        date: Date = .now,
        note: String? = nil,
        isImportantDate: Bool = false
    ) {
        self.id = id
        self.personID = personID
        self.date = date
        self.note = note
        self.isImportantDate = isImportantDate
    }
}
