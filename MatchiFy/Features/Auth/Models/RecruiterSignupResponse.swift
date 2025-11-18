import Foundation

struct RecruiterSignupResponse: Codable {
    let message: String?
    let user: UserModel
    let token: String
    let role: String?  // Optional for backward compatibility
}

