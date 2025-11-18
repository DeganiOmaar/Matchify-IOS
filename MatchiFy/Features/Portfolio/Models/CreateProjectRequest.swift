import Foundation

struct CreateProjectRequest: Codable {
    let title: String
    let role: String?
    let skills: [String]?
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case title
        case role
        case skills
        case description
    }
}

