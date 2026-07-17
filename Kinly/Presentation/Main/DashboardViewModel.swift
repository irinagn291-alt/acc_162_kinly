import Foundation
import Observation

@MainActor
@Observable
final class DashboardViewModel {
    private(set) var rankings: [OverdueRanking] = []
    private(set) var isLoading = true
    private(set) var errorMessage: String?

    private let dependencies: AppDependencies

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            rankings = try await dependencies.overdueRankingUseCase.execute()
        } catch {
            errorMessage = "Couldn't load the list."
        }
    }

    func logContact(for ranking: OverdueRanking) async {
        do {
            _ = try await dependencies.logInteractionUseCase.execute(
                person: ranking.person,
                note: nil,
                isImportantDate: false
            )
            HapticsService.shared.playStarBrighten()
            await dependencies.reminderScheduler.scheduleGentleReminder(for: ranking.person)
            await load()
        } catch {
            errorMessage = "Couldn't save. Please try again."
        }
    }

    func subtitle(for ranking: OverdueRanking) -> String {
        if let last = ranking.lastInteractionDate {
            let days = max(0, Int(Date.now.timeIntervalSince(last) / 86_400))
            return "Last connection: \(RussianPlural.days(days)) ago"
        }
        return "No connections logged yet"
    }

    func reachOutCopy(for ranking: OverdueRanking) -> String {
        ReachOutMessageBuilder.body(
            personName: ranking.person.name,
            rhythmDays: ranking.person.contactRhythmDays
        )
    }
}
