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
        Task { @MainActor in
            isLoading = true
            errorMessage = nil
            
            do {
                let response = try await AuthService.shared.forgotPassword(email: email)
                print("✔ Code sent:", response.message)

                isLoading = false
                goNext = true
                
            } catch {
                isLoading = false
                errorMessage = extractError(error)
            }
        }
    }

    private func extractError(_ error: Error) -> String {
        if case ApiError.server(let msg) = error { return msg }
        return error.localizedDescription
    }
}
