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
        
        AuthManager.shared.logout()
        UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
        
        didLogout = true
        isLoggingOut = false
    }
}

