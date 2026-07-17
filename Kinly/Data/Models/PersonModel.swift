import Foundation
import SwiftData

@Model
final class PersonModel {
    @Attribute(.unique) var id: UUID
    var name: String
    var photoData: Data?
    var contactRhythmDays: Int
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \InteractionModel.person)
    var interactions: [InteractionModel]?

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
        self.interactions = []
    }
}

extension Person {
    init(_ model: PersonModel) {
        self.init(
            id: model.id,
            name: model.name,
            photoData: model.photoData,
            contactRhythmDays: model.contactRhythmDays,
            createdAt: model.createdAt
        )
    }
}
