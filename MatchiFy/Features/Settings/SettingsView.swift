import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var vm = SettingsViewModel()
    private let themes: [ThemeOption] = [.light, .dark, .system]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // MARK: - Theme Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Thème")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Text("Choisissez votre mode d'affichage préféré.")
                        .font(.system(size: 15))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                
                VStack(spacing: 12) {
                    ForEach(themes, id: \.self) { theme in
                        Button {
                            themeManager.setTheme(theme)
                        } label: {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(AppTheme.Colors.primary.opacity(0.12))
                                        .frame(width: 56, height: 56)
                                    
                                    Image(systemName: themeIcon(for: theme))
                                        .foregroundColor(AppTheme.Colors.primary)
                                        .font(.system(size: 22, weight: .semibold))
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(theme.displayName)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(AppTheme.Colors.textPrimary)
                                    
                                    Text(themeDescription(for: theme))
                                        .font(.system(size: 14))
                                        .foregroundColor(AppTheme.Colors.textSecondary)
                                }
                                
                                Spacer()
                                
                                if themeManager.currentTheme == theme {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(AppTheme.Colors.primary)
                                        .font(.system(size: 24))
                                }
                            }
                            .padding()
                            .background(AppTheme.Colors.cardBackground)
                            .cornerRadius(20)
                            .shadow(color: AppTheme.Colors.cardShadow, radius: 12, x: 0, y: 6)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // MARK: - Account Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Compte")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Text("Gérez votre session et assurez-vous de sécuriser vos données.")
                        .font(.system(size: 15))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                .padding(.top, 8)
                
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.Colors.primary.opacity(0.12))
                                .frame(width: 56, height: 56)
                            
                            Image(systemName: "lock.fill")
                                .foregroundColor(AppTheme.Colors.primary)
                                .font(.system(size: 22, weight: .semibold))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Déconnexion")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.textPrimary)
                            
                            Text("Terminez votre session actuelle.")
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                        
                        Spacer()
                        
                        Button {
                            vm.logout()
                        } label: {
                            if vm.isLoggingOut {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(width: 24, height: 24)
                            } else {
                                Text("Logout")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppTheme.Colors.primary)
                        .controlSize(.large)
                        .disabled(vm.isLoggingOut)
                    }
                    .padding()
                    .background(AppTheme.Colors.cardBackground)
                    .cornerRadius(20)
                    .shadow(color: AppTheme.Colors.cardShadow, radius: 12, x: 0, y: 6)
                    
                    if let error = vm.errorMessage {
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(24)
        }
        .background(AppTheme.Colors.groupedBackground)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: vm.didLogout) { _, newValue in
            if newValue {
                dismiss()
            }
        }
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
    
    private func themeDescription(for theme: ThemeOption) -> String {
        switch theme {
        case .light:
            return "Mode clair par défaut"
        case .dark:
            return "Mode sombre par défaut"
        case .system:
            return "Suivre les paramètres système"
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(ThemeManager.shared)
    }
}
