import Foundation

/// A close person the user wants to stay in touch with.
struct Person: Identifiable, Hashable, Sendable {
    let id: UUID
    var name: String
    var photoData: Data?
    var contactRhythmDays: Int
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        photoData: Data? = nil,
        contactRhythmDays: Int = 7,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.photoData = photoData
        self.contactRhythmDays = contactRhythmDays
        self.createdAt = createdAt
    }
}
