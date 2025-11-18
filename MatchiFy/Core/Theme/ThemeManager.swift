import SwiftUI
import Combine

enum ThemeOption: String, CaseIterable {
    case light = "light"
    case dark = "dark"
    case system = "system"
    
    var displayName: String {
        switch self {
        case .light:
            return "Light Mode"
        case .dark:
            return "Dark Mode"
        case .system:
            return "System Default"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil // nil means use system default
        }
    }
}

@MainActor
final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: ThemeOption = .system {
        didSet {
            saveTheme()
        }
    }
    
    private let themeKey = "selectedAppTheme"
    
    private init() {
        loadTheme()
    }
    
    private func loadTheme() {
        if let savedTheme = UserDefaults.standard.string(forKey: themeKey),
           let theme = ThemeOption(rawValue: savedTheme) {
            currentTheme = theme
        } else {
            currentTheme = .system
        }
    }
    
    private func saveTheme() {
        UserDefaults.standard.set(currentTheme.rawValue, forKey: themeKey)
    }
    
    func setTheme(_ theme: ThemeOption) {
        currentTheme = theme
    }
}

