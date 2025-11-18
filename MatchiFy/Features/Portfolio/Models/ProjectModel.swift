import Foundation

struct ProjectModel: Codable, Identifiable {
    let id: String?
    let _id: String?
    let talentId: String
    let title: String
    let role: String?
    let media: [MediaItemModel]
    let skills: [String]
    let description: String?
    let projectLink: String?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case _id
        case talentId
        case title
        case role
        case media
        case skills
        case description
        case projectLink
        case createdAt
        case updatedAt
        // Old format support
        case mediaType
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try? container.decode(String.self, forKey: .id)
        _id = try? container.decode(String.self, forKey: ._id)
        talentId = try container.decode(String.self, forKey: .talentId)
        title = try container.decode(String.self, forKey: .title)
        role = try? container.decode(String.self, forKey: .role)
        skills = (try? container.decode([String].self, forKey: .skills)) ?? []
        description = try? container.decode(String.self, forKey: .description)
        projectLink = try? container.decode(String.self, forKey: .projectLink)
        createdAt = try? container.decode(String.self, forKey: .createdAt)
        updatedAt = try? container.decode(String.self, forKey: .updatedAt)
        
        // Handle both old format (media as string) and new format (media as array)
        if container.contains(.media) {
            if let mediaArray = try? container.decode([MediaItemModel].self, forKey: .media) {
                // New format: media is already an array
                media = mediaArray
            } else if let mediaString = try? container.decode(String.self, forKey: .media),
                      !mediaString.isEmpty {
                // Old format: convert string + mediaType to MediaItemModel array
                let mediaType = (try? container.decode(String.self, forKey: .mediaType)) ?? "image"
                let mediaItem = MediaItemModel(
                    type: mediaType,
                    url: mediaString,
                    title: nil,
                    externalLink: nil
                )
                media = [mediaItem]
            } else {
                // Empty or null media
                media = []
            }
        } else {
            // Media field doesn't exist (very old format)
            media = []
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(_id, forKey: ._id)
        try container.encode(talentId, forKey: .talentId)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(role, forKey: .role)
        try container.encode(media, forKey: .media)
        try container.encode(skills, forKey: .skills)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(projectLink, forKey: .projectLink)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
        // Note: We intentionally do not encode `mediaType`. It's only used for decoding legacy payloads.
    }
    
    var projectId: String {
        if let cleanId = id, !cleanId.isEmpty { return cleanId }
        if let cleanMongoId = _id, !cleanMongoId.isEmpty { return cleanMongoId }
        if let createdAt = createdAt, !createdAt.isEmpty { return createdAt }
        return UUID().uuidString
    }
    
    // First media item for preview (backward compatibility)
    var firstMediaItem: MediaItemModel? {
        return media.first
    }
    
    // First media URL for preview (backward compatibility)
    var firstMediaURL: URL? {
        return media.first?.mediaURL
    }
    
    // All images
    var images: [MediaItemModel] {
        return media.filter { $0.isImage }
    }
    
    // All videos
    var videos: [MediaItemModel] {
        return media.filter { $0.isVideo }
    }
    
    // All PDFs
    var pdfs: [MediaItemModel] {
        return media.filter { $0.isPdf }
    }
    
    // All external links
    var externalLinks: [MediaItemModel] {
        return media.filter { $0.isExternalLink }
    }
}

