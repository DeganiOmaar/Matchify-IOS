import Foundation
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var isLoggingOut: Bool = false
    @Published var errorMessage: String?
    @Published var didLogout: Bool = false
    
    func logout() {
        guard !isLoggingOut else { return }
        isLoggingOut = true
        errorMessage = nil
        
        Task { @MainActor in
            // Call async logout which handles backend call and local cleanup
            await AuthManager.shared.logout()
            
            // IMPORTANT: Do NOT reset hasSeenOnboarding
            // This ensures user goes to Login screen after logout, not onboarding
            
            didLogout = true
            isLoggingOut = false
        }
    }
}

