import Foundation

struct CreateMissionRequest: Codable {
    let title: String
    let description: String
    let duration: String
    let budget: Int
    let skills: [String]
}

