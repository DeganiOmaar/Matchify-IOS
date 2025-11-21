import SwiftUI

struct ThemeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager
    
    private let themes: [ThemeOption] = [.dark, .light, .system]
    
    var body: some View {
        VStack(spacing: 12) {
            // MARK: - Title
            Text("Theme")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primary)
                .padding(.top, 20)
                .padding(.bottom, 16)
            
            // MARK: - Theme Options
            VStack(spacing: 0) {
                ForEach(themes, id: \.self) { theme in
                    Button {
                        themeManager.setTheme(theme)
                        dismiss()
                    } label: {
                        HStack(spacing: 16) {
                            // Icon
                            Image(systemName: themeIcon(for: theme))
                                .font(.system(size: 20))
                                .foregroundColor(AppTheme.Colors.iconPrimary)
                                .frame(width: 24, height: 24)
                            
                            // Label
                            Text(themeLabel(for: theme))
                                .font(.system(size: 17))
                                .foregroundColor(AppTheme.Colors.textPrimary)
                            
                            Spacer()
                            
                            // Checkmark if selected
                            if themeManager.currentTheme == theme {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(AppTheme.Colors.primary)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    
                    // Divider (except after last item)
                    if theme != themes.last {
                        Divider()
                            .background(AppTheme.Colors.border.opacity(0.3))
                            .padding(.leading, 56)
                    }
                }
            }
            .padding(.bottom, 20)
        }
        .background(AppTheme.Colors.groupedBackground)
        .presentationDetents([.height(220)])
        .presentationDragIndicator(.visible)
        .presentationBackground {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppTheme.Colors.groupedBackground)
        }
        .presentationCornerRadius(16)
    }
    
    private func themeIcon(for theme: ThemeOption) -> String {
        switch theme {
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        case .system:
            return "gearshape.fill"
        }
    }
    
    private func themeLabel(for theme: ThemeOption) -> String {
        switch theme {
        case .light:
            return "Light mode"
        case .dark:
            return "Dark mode"
        case .system:
            return "System"
        }
    }
}

#Preview {
    ThemeView()
        .environmentObject(ThemeManager.shared)
}

