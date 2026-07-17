import Foundation

/// Pure calculation of how brightly a person's star should shine, based on how
/// fresh contact feels relative to their desired rhythm. A relationship never
/// "goes dark" entirely — it only dims, in keeping with Kinly's gentle tone.
struct StarBrightnessCalculator {
    static let minimumBrightness = 0.16

    func brightness(lastInteractionDate: Date?, rhythmDays: Int, now: Date = .now) -> Double {
        guard let lastInteractionDate else { return Self.minimumBrightness }
        let ratio = overdueRatio(lastInteractionDate: lastInteractionDate, rhythmDays: rhythmDays, now: now)
        let value = 1.5 - 0.5 * ratio
        return min(1.0, max(Self.minimumBrightness, value))
    }

    /// 0 means "right on rhythm", 1 means "exactly at the edge of the desired rhythm",
    /// growing beyond 1 the longer it has been.
    func overdueRatio(lastInteractionDate: Date?, rhythmDays: Int, now: Date = .now) -> Double {
        guard let lastInteractionDate else { return .infinity }
        let rhythm = max(1, rhythmDays)
        let daysSince = max(0, now.timeIntervalSince(lastInteractionDate) / 86_400)
        return daysSince / Double(rhythm)
    }
}
