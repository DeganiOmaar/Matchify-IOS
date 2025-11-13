import Foundation

final class AuthService {
    static let shared = AuthService()
    private init() {}
    
    // MARK: - LOGIN
    func login(email: String, password: String) async throws -> LoginResponse {
        let body = LoginRequest(email: email, password: password)
        return try await ApiClient.shared.post(
            url: Endpoints.login,
            body: body
        )
    }
    
    // MARK: - SIGNUP TALENT
    func signupTalent(_ body: TalentSignupRequest) async throws -> TalentSignupResponse {
        return try await ApiClient.shared.post(
            url: Endpoints.signupTalent,
            body: body
        )
    }
    
    // MARK: - SIGNUP RECRUITER
    func signupRecruiter(_ body: RecruiterSignupRequest) async throws -> RecruiterSignupResponse {
        return try await ApiClient.shared.post(
            url: Endpoints.signupRecruiter,
            body: body
        )
    }
    
    // MARK: - FORGOT PASSWORD
    func forgotPassword(email: String) async throws -> ForgotPasswordResponse {
        let body = ForgotPasswordRequest(email: email)
        return try await ApiClient.shared.post(
            url: Endpoints.forgotPassword,
            body: body
        )
    }
    
    // MARK: - VERIFY RESET CODE
    func verifyResetCode(code: String) async throws -> VerifyResetCodeResponse {
        let body = VerifyResetCodeRequest(code: code)
        return try await ApiClient.shared.post(
            url: Endpoints.verifyResetCode,
            body: body
        )
    }
    
    // MARK: - RESET PASSWORD
    func resetPassword(newPassword: String, confirmPassword: String) async throws -> ResetPasswordResponse {
        let body = ResetPasswordRequest(
            newPassword: newPassword,
            confirmPassword: confirmPassword
        )
        return try await ApiClient.shared.post(
            url: Endpoints.resetPassword,
            body: body
        )
    }
}
