import Foundation
import Combine

final class ForgotPasswordViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var goNext = false   // navigation trigger

    var isButtonDisabled: Bool {
        email.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    func sendCode() {
        errorMessage = nil
        
        // Validation
        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Veuillez entrer votre adresse email."
            return
        }
        
        Task { @MainActor in
            isLoading = true
            
            do {
                let response = try await AuthService.shared.forgotPassword(email: email)
                print("✔ Code sent:", response.message)

                isLoading = false
                goNext = true
                
            } catch {
                isLoading = false
                errorMessage = ErrorHandler.getErrorMessage(from: error, context: .forgotPassword)
            }
        }
    }
}
