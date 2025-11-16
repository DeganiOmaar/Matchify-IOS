import Foundation
import Combine

final class RecruiterSignupViewModel: ObservableObject {
    @Published var fullName = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var showPassword = false
    @Published var showConfirmPassword = false

    @Published var isLoading = false
    @Published var error: String?
    @Published var goToHome = false

    var isSignUpDisabled: Bool {
        fullName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty
    }

    func signUp() {
        error = nil
        
        // Validation
        if fullName.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            error = "Veuillez remplir tous les champs requis."
            return
        }
        
        if password != confirmPassword {
            error = "Les mots de passe ne correspondent pas."
            return
        }
        
        if password.count < 6 {
            error = "Le mot de passe doit contenir au moins 6 caractères."
            return
        }
        
        let body = RecruiterSignupRequest(
            fullName: fullName,
            email: email,
            password: password,
            confirmPassword: confirmPassword
        )

        Task { @MainActor in
            isLoading = true
            
            do {
                let response = try await AuthService.shared.signupRecruiter(body)
                
                print("🎉 Recruiter created:", response.user.fullName)
                print("🔐 Token:", response.token)
                
                isLoading = false
                goToHome = true

            } catch {
                isLoading = false
                self.error = extractError(error)
            }
        }
    }

    private func extractError(_ error: Error) -> String {
        return ErrorHandler.getErrorMessage(from: error, context: .signup)
    }
}
