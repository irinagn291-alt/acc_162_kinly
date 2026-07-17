import Foundation

#if DEBUG
/// Demo-only seed data for DEBUG builds. Seeding runs on simulator only.
@MainActor
enum DebugSeedData {
    static let firstLaunchKey = "kinly.debug.didAutoSeed"

    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        true
        #else
        false
        #endif
    }

    static var shouldAutoSeed: Bool {
        guard isSimulator else { return false }
        let args = ProcessInfo.processInfo.arguments
        let demoMode = args.contains("-demoMode")
        let firstLaunch = !UserDefaults.standard.bool(forKey: firstLaunchKey)
        return demoMode || firstLaunch
    }

    static func loadIfNeeded(into dependencies: AppDependencies) async {
        guard shouldAutoSeed else { return }
        do {
            let people = try await dependencies.personRepository.fetchAll()
            guard people.isEmpty else {
                UserDefaults.standard.set(true, forKey: firstLaunchKey)
                return
            }
            try await seed(into: dependencies)
            UserDefaults.standard.set(true, forKey: firstLaunchKey)
        } catch {
            // Demo seed is best-effort; ignore failures in debug tooling.
        }
    }

    static func seed(into dependencies: AppDependencies) async throws {
        let calendar = Calendar.current
        let now = Date()

        let people: [(Person, Date?, String?, Bool)] = [
            (
                Person(name: "Maya", contactRhythmDays: 3),
                calendar.date(byAdding: .day, value: -1, to: now),
                "Quick walk and coffee — felt easy.",
                false
            ),
            (
                Person(name: "Jonah", contactRhythmDays: 7),
                calendar.date(byAdding: .day, value: -2, to: now),
                "Voice note about his new playlist.",
                false
            ),
            (
                Person(name: "Elena", contactRhythmDays: 14),
                calendar.date(byAdding: .day, value: -20, to: now),
                nil,
                false
            ),
            (
                Person(name: "Priya", contactRhythmDays: 21),
                calendar.date(byAdding: .day, value: -45, to: now),
                "Long overdue catch-up still pending.",
                false
            ),
            (
                Person(name: "Sam", contactRhythmDays: 10),
                calendar.date(byAdding: .day, value: -4, to: now),
                "Birthday dinner — keep this date close.",
                true
            ),
        ]

        for (person, lastDate, note, important) in people {
            try await dependencies.personRepository.add(person)
            if let lastDate {
                let interaction = Interaction(
                    personID: person.id,
                    date: lastDate,
                    note: note,
                    isImportantDate: important
                )
                try await dependencies.interactionRepository.add(interaction)
            }
            // Extra older touch for Maya so the timeline isn't a single row.
            if person.name == "Maya",
               let earlier = calendar.date(byAdding: .day, value: -8, to: now) {
                try await dependencies.interactionRepository.add(
                    Interaction(personID: person.id, date: earlier, note: "Sent a meme that landed.")
                )
            }
        }
    }

    static func reset(into dependencies: AppDependencies) async throws {
        try await dependencies.interactionRepository.deleteAll()
        try await dependencies.personRepository.deleteAll()
        await dependencies.reminderScheduler.cancelAll()
        UserDefaults.standard.set(false, forKey: firstLaunchKey)
    }
}
#endif
