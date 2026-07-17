import SwiftUI

/// Shared `Canvas` drawing helpers for rendering soft, glowing stars.
enum StarDrawing {
    static func drawGlowingStar(in context: inout GraphicsContext, at point: CGPoint, brightness: Double, radius: CGFloat) {
        let clampedBrightness = min(1, max(0, brightness))

        let glowRadius = radius * (2.4 + clampedBrightness * 1.6)
        let glowRect = CGRect(x: point.x - glowRadius, y: point.y - glowRadius, width: glowRadius * 2, height: glowRadius * 2)
        let glowGradient = Gradient(colors: [
            AppColor.primary.opacity(0.4 * clampedBrightness),
            AppColor.primary.opacity(0)
        ])
        context.fill(
            Path(ellipseIn: glowRect),
            with: .radialGradient(glowGradient, center: point, startRadius: 0, endRadius: glowRadius)
        )

        let coreRect = CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)
        context.fill(
            Path(ellipseIn: coreRect),
            with: .color(AppColor.text.opacity(0.35 + 0.65 * clampedBrightness))
        )
    }
}
