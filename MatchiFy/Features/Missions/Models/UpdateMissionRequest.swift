import Foundation

struct UpdateMissionRequest: Codable {
    let title: String?
    let description: String?
    let duration: String?
    let budget: Int?
    let skills: [String]?
    
    enum CodingKeys: String, CodingKey {
        case title
        case description
        case duration
        case budget
        case skills
    }
    
    /// Only encode non-nil values
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(duration, forKey: .duration)
        try container.encodeIfPresent(budget, forKey: .budget)
        try container.encodeIfPresent(skills, forKey: .skills)
    }
}

