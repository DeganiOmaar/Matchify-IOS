import Foundation

struct SkillModel: Codable, Identifiable, Hashable {
    let id: String?
    let _id: String?
    let name: String
    let source: String // "ESCO" or "USER"
    let createdBy: String?
    let createdAt: String?
    let updatedAt: String?
    
    // Unique identifier for Identifiable protocol - always returns a non-nil value
    // This ensures ForEach can properly identify each skill
    // IMPORTANT: This must return the same value for the same SkillModel instance
    var uniqueId: String {
        // Priority: _id > id > name-based fallback
        if let cleanId = _id, !cleanId.isEmpty { return cleanId }
        if let cleanId = id, !cleanId.isEmpty { return cleanId }
        // For custom skills without ID, use name-based identifier
        // This ensures same-named skills from backend are treated as the same
        // But custom skills created locally will have UUID in id field
        return "custom-\(name.lowercased().replacingOccurrences(of: " ", with: "-"))"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case _id
        case name
        case source
        case createdBy
        case createdAt
        case updatedAt
    }
    
    init(id: String? = nil, _id: String? = nil, name: String, source: String, createdBy: String? = nil, createdAt: String? = nil, updatedAt: String? = nil) {
        self.id = id
        self._id = _id
        self.name = name
        self.source = source
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    var skillId: String {
        return uniqueId
    }
    
    var isEsco: Bool {
        return source == "ESCO"
    }
    
    var isUserCreated: Bool {
        return source == "USER"
    }
    
    static func == (lhs: SkillModel, rhs: SkillModel) -> Bool {
        // Compare by name (case-insensitive) since we work with names now
        lhs.name.lowercased() == rhs.name.lowercased()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name.lowercased())
    }
}

