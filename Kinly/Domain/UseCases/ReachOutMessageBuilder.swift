import Foundation

/// Builds warm, non-guilt-tripping copy for gentle reach-out reminders.
/// Phrased so it reads naturally for any name as a free-form variable.
struct ReachOutMessageBuilder {
    static func body(personName: String, rhythmDays: Int) -> String {
        "\(personName) — it's been \(elapsedPhrase(forDays: rhythmDays)) without a catch-up. Maybe a short call today?"
    }

    private static func elapsedPhrase(forDays days: Int) -> String {
        if days >= 30, days % 30 == 0 {
            return RussianPlural.months(days / 30)
        }
        if days >= 7, days % 7 == 0 {
            return RussianPlural.weeks(days / 7)
        }
        return RussianPlural.days(days)
    }
}
