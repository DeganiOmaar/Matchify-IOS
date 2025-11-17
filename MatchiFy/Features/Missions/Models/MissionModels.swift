import Foundation

// MARK: - Mission Model
struct MissionModel: Codable, Identifiable {
    let id: String?            // Sometimes backend uses "id"
    let _id: String?           // MongoDB uses "_id"
    let title: String
    let description: String
    let duration: String
    let budget: Int
    let skills: [String]
    let recruiterId: String
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case _id
        case title
        case description
        case duration
        case budget
        case skills
        case recruiterId
        case createdAt
        case updatedAt
    }
    
    /// Get the mission ID (handles both id and _id)
    var missionId: String {
        if let cleanId = id, !cleanId.isEmpty { return cleanId }
        if let cleanMongoId = _id, !cleanMongoId.isEmpty { return cleanMongoId }
        if let createdAt = createdAt, !createdAt.isEmpty { return createdAt }
        return UUID().uuidString
    }
    
    /// Formatted date string for display
    var formattedDate: String {
        guard let createdAt = createdAt else { return "-" }
        
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = iso.date(from: createdAt) {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "fr_FR")
            formatter.dateFormat = "dd MMM yyyy"
            return formatter.string(from: date)
        }
        
        return "-"
    }
    
    /// Formatted budget string
    var formattedBudget: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        return "\(formatter.string(from: NSNumber(value: budget)) ?? "\(budget)") €"
    }
}

// MARK: - Create Mission Request
struct CreateMissionRequest: Codable {
    let title: String
    let description: String
    let duration: String
    let budget: Int
    let skills: [String]
}

// MARK: - Update Mission Request
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

// MARK: - Mission Response (for single mission)
typealias MissionResponse = MissionModel

// MARK: - Missions Response (for array of missions)
typealias MissionsResponse = [MissionModel]

