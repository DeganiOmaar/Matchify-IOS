import Foundation

struct LoginResponse: Codable {
    let message: String
    let token: String
    let role: String
    let user: UserModel
}

