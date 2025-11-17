import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = SettingsViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Compte")
                        .font(.system(size: 22, weight: .semibold))
                    
                    Text("Gérez votre session et assurez-vous de sécuriser vos données.")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
                
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.12))
                                .frame(width: 56, height: 56)
                            
                            Image(systemName: "lock.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 22, weight: .semibold))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Déconnexion")
                                .font(.system(size: 18, weight: .semibold))
                            
                            Text("Terminez votre session actuelle.")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
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
                        .tint(.blue)
                        .controlSize(.large)
                        .disabled(vm.isLoggingOut)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 6)
                    
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
        .background(Color(.systemGroupedBackground))
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

