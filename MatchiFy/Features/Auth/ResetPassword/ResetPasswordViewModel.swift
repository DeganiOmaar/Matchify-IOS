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
        
        guard newPassword == confirmPassword else {
            errorMessage = "Passwords do not match."
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
                errorMessage = extractError(error)
            }
        }
    }
    
    private func extractError(_ error: Error) -> String {
        if case ApiError.server(let msg) = error { return msg }
        return error.localizedDescription
    }
}
