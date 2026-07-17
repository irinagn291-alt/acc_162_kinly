import UIKit

/// The one permitted app-wide singleton: a stateless wrapper around haptic feedback.
final class HapticsService {
    static let shared = HapticsService()

    private init() {}

    /// A soft haptic for the "moment of outcome" when a star brightens after logging contact.
    @MainActor
    func playStarBrighten() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred()
    }
}
