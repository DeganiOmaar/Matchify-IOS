import Foundation

// MARK: - Login Request
struct LoginRequest: Codable {
    let email: String
    let password: String
}

// MARK: - LOGIN User Model
struct UserModel: Codable {
    let id: String?            // Sometimes backend uses "id"
    let _id: String?           // MongoDB uses "_id"
    let fullName: String
    let email: String
    let role: String
    let phone: String?
    let profileImage: String?
    let location: String?
    let talent: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case _id
        case fullName
        case email
        case role
        case phone
        case profileImage
        case location
        case talent
    }
}

// MARK: - Login Response
struct LoginResponse: Codable {
    let message: String
    let token: String
    let role: String
    let user: UserModel
}

// MARK: - Talent Signup Request
struct TalentSignupRequest: Codable {
    let fullName: String
    let email: String
    let password: String
    let confirmPassword: String
    let phone: String
    let profileImage: String
    let location: String
    let talent: String
}

// MARK: - Recruiter Signup Request
struct RecruiterSignupRequest: Codable {
    let fullName: String
    let email: String
    let password: String
    let confirmPassword: String
}

// MARK: - Talent Signup Response
struct TalentSignupResponse: Codable {
    let user: UserModel
    let token: String
}

// MARK: - Recruiter Signup Response
struct RecruiterSignupResponse: Codable {
    let user: UserModel
    let token: String
}

// MARK: - Forgot Password Request
struct ForgotPasswordRequest: Codable {
    let email: String
}

// MARK: - Forgot Password Response
struct ForgotPasswordResponse: Codable {
    let message: String
    let expiresIn: String?
}

// MARK: - Verify Reset Code
struct VerifyResetCodeRequest: Codable {
    let code: String
}

struct VerifyResetCodeResponse: Codable {
    let message: String
    let verified: Bool
}

// MARK: - Reset Password
struct ResetPasswordRequest: Codable {
    let newPassword: String
    let confirmPassword: String
}

struct ResetPasswordResponse: Codable {
    let message: String
}
