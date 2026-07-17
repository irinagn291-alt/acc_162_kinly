import Foundation
import SwiftData

@Model
final class InteractionModel {
    @Attribute(.unique) var id: UUID
    var date: Date
    var note: String?
    var isImportantDate: Bool
    var person: PersonModel?

    init(
        id: UUID = UUID(),
        date: Date = .now,
        note: String? = nil,
        isImportantDate: Bool = false,
        person: PersonModel? = nil
    ) {
        self.id = id
        self.date = date
        self.note = note
        self.isImportantDate = isImportantDate
        self.person = person
    }
}

extension Interaction {
    init(_ model: InteractionModel) {
        self.init(
            id: model.id,
            personID: model.person?.id ?? UUID(),
            date: model.date,
            note: model.note,
            isImportantDate: model.isImportantDate
        )
    }
}
