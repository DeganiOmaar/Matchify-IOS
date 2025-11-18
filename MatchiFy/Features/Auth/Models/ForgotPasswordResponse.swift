import Foundation

struct ForgotPasswordResponse: Codable {
    let message: String
    let expiresIn: String?
}

