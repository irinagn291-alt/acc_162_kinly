import Foundation
import SwiftData

/// Lightweight composition root wiring repositories and use cases for the views.
/// No singletons other than `HapticsService` are used anywhere in the app.
@MainActor
final class AppDependencies {
    let personRepository: PersonRepository
    let interactionRepository: InteractionRepository
    let contactsImportRepository: ContactsImportRepository
    let reminderScheduler: ReminderScheduler

    let logInteractionUseCase: LogInteractionUseCase
    let overdueRankingUseCase: OverdueRankingUseCase
    let conversationStarterProvider: ConversationStarterProvider

    init(modelContext: ModelContext) {
        let personRepository = SwiftDataPersonRepository(modelContext: modelContext)
        let interactionRepository = SwiftDataInteractionRepository(modelContext: modelContext)

        self.personRepository = personRepository
        self.interactionRepository = interactionRepository
        self.contactsImportRepository = SystemContactsImportRepository()
        self.reminderScheduler = LocalNotificationReminderScheduler()

        self.logInteractionUseCase = LogInteractionUseCase(interactionRepository: interactionRepository)
        self.overdueRankingUseCase = OverdueRankingUseCase(
            personRepository: personRepository,
            interactionRepository: interactionRepository
        )
        self.conversationStarterProvider = ConversationStarterProvider()
    }
}
