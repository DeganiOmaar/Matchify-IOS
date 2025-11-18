import SwiftUI

struct AppTheme {
    struct Colors {
        // Primary accent color (blue) - same in both themes
        static let primary = Color.blue
        
        // Background colors
        static var background: Color {
            Color(.systemBackground)
        }
        
        static var secondaryBackground: Color {
            Color(.secondarySystemBackground)
        }
        
        static var groupedBackground: Color {
            Color(.systemGroupedBackground)
        }
        
        // Text colors
        static var textPrimary: Color {
            Color.primary
        }
        
        static var textSecondary: Color {
            Color.secondary
        }
        
        // Card colors
        static var cardBackground: Color {
            Color(.systemBackground)
        }
        
        static var cardShadow: Color {
            Color.black.opacity(0.05)
        }
        
        // Input colors
        static var inputBackground: Color {
            Color(.secondarySystemBackground)
        }
        
        static var inputBorder: Color {
            Color.gray.opacity(0.2)
        }
        
        // Button colors
        static var buttonBackground: Color {
            Color.blue
        }
        
        static var buttonText: Color {
            Color.white
        }
        
        // Border colors
        static var border: Color {
            Color.gray.opacity(0.2)
        }
        
        // Icon colors
        static var iconPrimary: Color {
            Color.primary
        }
        
        static var iconSecondary: Color {
            Color.secondary
        }
        
        // Navigation bar
        static var navigationBarBackground: Color {
            Color(.systemBackground)
        }
        
        // Tab bar
        static var tabBarBackground: Color {
            Color(.systemBackground)
        }
        
        // Overlay colors
        static var overlay: Color {
            Color.black.opacity(0.1)
        }
    }
}
