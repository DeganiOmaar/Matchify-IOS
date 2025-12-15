import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = SettingsViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // MARK: - Settings Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Settings")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Text("Manage your preferences and account settings.")
                        .font(.system(size: 15))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                .padding(.top, 8)
                
                // Settings Menu Items
                VStack(spacing: 0) {
                    SettingsMenuItem(
                        icon: "person.fill",
                        title: "Contact Info",
                        subtitle: "Manage your contact details",
                        onClick: { /* TODO: Navigate to Contact Info */ }
                    )
                    
                    SettingsDivider()
                    
                    SettingsMenuItem(
                        icon: "person.3.fill",
                        title: "My Teams",
                        subtitle: "Manage your teams",
                        onClick: { /* TODO: Navigate to My Teams */ }
                    )
                    
                    SettingsDivider()
                    
                    SettingsMenuItem(
                        icon: "lock.fill",
                        title: "Password & Security",
                        subtitle: "Secure your account",
                        onClick: { /* TODO: Navigate to Password & Security */ }
                    )
                    
                    SettingsDivider()
                    
                    SettingsMenuItem(
                        icon: "bell.fill",
                        title: "Notifications Settings",
                        subtitle: "Manage your notifications",
                        onClick: { /* TODO: Navigate to Notifications Settings */ }
                    )
                    
                    SettingsDivider()
                    
                    SettingsMenuItem(
                        icon: "questionmark.circle.fill",
                        title: "App Support",
                        subtitle: "Get help",
                        onClick: { /* TODO: Navigate to App Support */ }
                    )
                    
                    SettingsDivider()
                    
                    SettingsMenuItem(
                        icon: "message.fill",
                        title: "Feedback",
                        subtitle: "Share your feedback",
                        onClick: { /* TODO: Navigate to Feedback */ }
                    )
                }
                .background(AppTheme.Colors.cardBackground)
                .cornerRadius(20)
                .shadow(color: AppTheme.Colors.cardShadow, radius: 12, x: 0, y: 6)
                
                // MARK: - Account Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Account")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Text("Manage your session and ensure your data is secure.")
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
}

// MARK: - Helper Components
struct SettingsMenuItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let onClick: () -> Void
    
    var body: some View {
        Button(action: onClick) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundColor(AppTheme.Colors.primary)
                    .font(.system(size: 20))
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(AppTheme.Colors.textSecondary.opacity(0.6))
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsDivider: View {
    var body: some View {
        Divider()
            .background(AppTheme.Colors.textSecondary.opacity(0.2))
            .padding(.horizontal, 16)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
