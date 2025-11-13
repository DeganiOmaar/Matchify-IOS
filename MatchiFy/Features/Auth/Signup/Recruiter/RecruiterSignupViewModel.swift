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
        let body = RecruiterSignupRequest(
            fullName: fullName,
            email: email,
            password: password,
            confirmPassword: confirmPassword
        )

        Task { @MainActor in
            isLoading = true
            error = nil
            
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
        if case ApiError.server(let msg) = error {
            return msg
        }
        return error.localizedDescription
    }
}
