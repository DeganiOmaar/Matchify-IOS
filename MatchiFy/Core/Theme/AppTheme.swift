import SwiftUI

struct AppTheme {
    struct Colors {
        static let primary = Color("PrimaryBlue")   // from Assets
        static let background = Color(.systemBackground)
        static let textPrimary = Color.primary
        static let textSecondary = Color.gray
        static let inputBackground = Color(.secondarySystemBackground)
        static let inputBorder = Color.gray.opacity(0.2)
    }
}
