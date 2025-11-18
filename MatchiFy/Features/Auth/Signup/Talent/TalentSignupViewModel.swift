import Foundation
import Combine

final class TalentSignupViewModel: ObservableObject {
    @Published var fullName = ""
    @Published var email = ""
    @Published var phone = ""
    @Published var profileImage = ""
    @Published var password = ""
    @Published var confirmPassword = ""

    @Published var showPassword = false
    @Published var showConfirmPassword = false

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var goToHome = false

    var isSignUpDisabled: Bool {
        fullName.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty
    }

    func signUp() {
        errorMessage = nil
        
        // Validation
        if fullName.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            errorMessage = "Veuillez remplir tous les champs requis."
            return
        }
        
        if password != confirmPassword {
            errorMessage = "Les mots de passe ne correspondent pas."
            return
        }
        
        if password.count < 6 {
            errorMessage = "Le mot de passe doit contenir au moins 6 caractères."
            return
        }
        
        // Only include profileImage if it's not empty
        let body = TalentSignupRequest(
            fullName: fullName,
            email: email,
            password: password,
            confirmPassword: confirmPassword,
            phone: phone,
            profileImage: profileImage.isEmpty ? nil : profileImage
        )

        Task { @MainActor in
            isLoading = true
            
            do {
                let response = try await AuthService.shared.signupTalent(body)

                print("🎉 Talent created:", response.user.fullName)
                print("🔐 Token:", response.token)
                
                // Save session in AuthManager (same as login)
                AuthManager.shared.saveSignupSession(
                    token: response.token,
                    user: response.user,
                    rememberMe: true  // Always remember after signup
                )
                
                isLoading = false
                // Navigation will be handled automatically by AppEntryView
                // when isLoggedIn changes to true
                
            } catch {
                isLoading = false
                errorMessage = extractError(error)
            }
        }
    }

    private func extractError(_ error: Error) -> String {
        return ErrorHandler.getErrorMessage(from: error, context: .signup)
    }
}
