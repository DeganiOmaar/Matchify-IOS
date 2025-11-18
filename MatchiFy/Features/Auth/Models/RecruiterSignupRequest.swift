import Foundation

struct RecruiterSignupRequest: Codable {
    let fullName: String
    let email: String
    let password: String
    let confirmPassword: String
}

