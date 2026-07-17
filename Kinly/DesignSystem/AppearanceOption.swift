import SwiftUI

/// User-selectable appearance, persisted via `@AppStorage` at the call sites.
enum AppearanceOption: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    static let storageKey = "kinly.appearance"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}
