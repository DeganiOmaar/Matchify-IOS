import Foundation

struct ProjectModel: Codable, Identifiable {
    let id: String?
    let _id: String?
    let talentId: String
    let title: String
    let role: String?
    let media: String?
    let mediaType: String?
    let skills: [String]
    let description: String?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case _id
        case talentId
        case title
        case role
        case media
        case mediaType
        case skills
        case description
        case createdAt
        case updatedAt
    }
    
    var projectId: String {
        if let cleanId = id, !cleanId.isEmpty { return cleanId }
        if let cleanMongoId = _id, !cleanMongoId.isEmpty { return cleanMongoId }
        if let createdAt = createdAt, !createdAt.isEmpty { return createdAt }
        return UUID().uuidString
    }
    
    var mediaURL: URL? {
        guard var path = media?.trimmingCharacters(in: .whitespacesAndNewlines),
              !path.isEmpty else {
            return nil
        }
        // Backend stores path as "uploads/portfolio/filename" or "/uploads/portfolio/filename"
        // Ensure it starts with / for URL construction
        if !path.hasPrefix("/") {
            path = "/" + path
        }
        let fullUrlString = Endpoints.baseURL + path
        print("📸 Portfolio media URL: \(fullUrlString) (from path: \(media ?? "nil"))")
        return URL(string: fullUrlString)
    }
    
    var isVideo: Bool {
        return mediaType == "video"
    }
    
    var isImage: Bool {
        return mediaType == "image" || (mediaType == nil && media != nil)
    }
}

