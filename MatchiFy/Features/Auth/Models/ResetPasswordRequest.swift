import Foundation

struct ResetPasswordRequest: Codable {
    let newPassword: String
    let confirmPassword: String
}

