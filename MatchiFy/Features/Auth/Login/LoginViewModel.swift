import Foundation
import Combine

final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var showPassword = false
    @Published var isLoading = false
    @Published var error: String?

    var isLoginButtonDisabled: Bool {
        email.isEmpty || password.isEmpty
    }

    // 🔥 UPDATED: now requires rememberMe
    @MainActor
    func login(rememberMe: Bool, completion: @escaping (LoginResponse?) -> Void) {
        isLoading = true
        error = nil

        Task {
            do {
                let response = try await AuthService.shared.login(
                    email: email,
                    password: password
                )

                // 🔥 Save session with or without persistence
                AuthManager.shared.saveLoginSession(
                    from: response,
                    rememberMe: rememberMe
                )

                isLoading = false
                completion(response)

            } catch {
                isLoading = false
                self.error = extractError(error)
                completion(nil)
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
