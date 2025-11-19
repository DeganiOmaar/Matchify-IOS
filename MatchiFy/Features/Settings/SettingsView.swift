import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = SettingsViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
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
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
