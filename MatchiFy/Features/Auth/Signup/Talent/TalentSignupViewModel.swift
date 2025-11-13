import Foundation
import Combine

final class TalentSignupViewModel: ObservableObject {
    @Published var fullName = ""
    @Published var email = ""
    @Published var phone = ""
    @Published var location = ""
    @Published var talent = ""
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
        location.isEmpty ||
        talent.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty
    }

    func signUp() {
        let body = TalentSignupRequest(
            fullName: fullName,
            email: email,
            password: password,
            confirmPassword: confirmPassword,
            phone: phone,
            profileImage: profileImage,
            location: location,
            talent: talent
        )

        Task { @MainActor in
            isLoading = true
            errorMessage = nil
            
            do {
                let response = try await AuthService.shared.signupTalent(body)

                print("🎉 Talent created:", response.user.fullName)
                print("🔐 Token:", response.token)
                
                isLoading = false
                goToHome = true
                
            } catch {
                isLoading = false
                errorMessage = extractError(error)
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
