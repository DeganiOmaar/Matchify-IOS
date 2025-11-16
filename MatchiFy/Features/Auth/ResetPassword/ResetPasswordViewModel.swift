import Foundation
import Combine

final class ResetPasswordViewModel: ObservableObject {
    @Published var newPassword: String = ""
    @Published var confirmPassword: String = ""
    
    @Published var showNewPassword: Bool = false
    @Published var showConfirmPassword: Bool = false
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var goToLogin: Bool = false
    
    var isButtonDisabled: Bool {
        newPassword.isEmpty || confirmPassword.isEmpty
    }
    
    func resetPassword() {
        errorMessage = nil
        
        // Validation
        if newPassword.isEmpty || confirmPassword.isEmpty {
            errorMessage = "Veuillez remplir tous les champs."
            return
        }
        
        guard newPassword == confirmPassword else {
            errorMessage = "Les mots de passe ne correspondent pas."
            return
        }
        
        if newPassword.count < 6 {
            errorMessage = "Le mot de passe doit contenir au moins 6 caractères."
            return
        }
        
        Task { @MainActor in
            isLoading = true
            
            do {
                let response = try await AuthService.shared.resetPassword(
                    newPassword: newPassword,
                    confirmPassword: confirmPassword
                )
                
                print("✔ Reset done:", response.message)

                isLoading = false
                goToLogin = true

            } catch {
                isLoading = false
                errorMessage = ErrorHandler.getErrorMessage(from: error, context: .passwordReset)
            }
        }
    }
}
