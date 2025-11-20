import Foundation

struct GetUserResponse: Codable {
    let message: String
    let user: UserModel
    let portfolio: [ProjectModel]? // Optional portfolio for talents
}

