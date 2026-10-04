import SwiftUI
import Combine

enum AppTheme: String, CaseIterable, Identifiable {
    case system, light, dark, ocean, forest, sunset, royal, minimal
    var id: String { rawValue }

    var label: String { rawValue.capitalized }

    var symbol: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .ocean: return "water.waves"
        case .forest: return "leaf.fill"
        case .sunset: return "sun.horizon.fill"
        case .royal: return "crown.fill"
        case .minimal: return "square.fill"
        }
    }

    var accent: Color {
        switch self {
        case .system: return .accentColor
        case .light: return Color(red: 0.95, green: 0.6, blue: 0.1)
        case .dark: return Color(red: 0.55, green: 0.45, blue: 0.95)
        case .ocean: return Color(red: 0.05, green: 0.62, blue: 0.68)
        case .forest: return Color(red: 0.15, green: 0.55, blue: 0.3)
        case .sunset: return Color(red: 0.9, green: 0.35, blue: 0.3)
        case .royal: return Color(red: 0.45, green: 0.3, blue: 0.85)
        case .minimal: return Color.primary
        }
    }

    var gradient: LinearGradient {
        LinearGradient(colors: [accent, accent.opacity(0.55)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .light, .ocean, .forest, .sunset: return .light
        case .dark, .royal: return .dark
        default: return nil
        }
    }
}

final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    @Published var current: AppTheme {
        didSet { UserDefaults.standard.set(current.rawValue, forKey: Pref.theme) }
    }

    private init() {
        let raw = UserDefaults.standard.string(forKey: Pref.theme) ?? "system"
        current = AppTheme(rawValue: raw) ?? .system
    }
}
