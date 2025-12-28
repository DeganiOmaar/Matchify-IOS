import Foundation

struct MissionModel: Codable, Identifiable, Hashable {
    let id: String?            // Sometimes backend uses "id"
    let _id: String?           // MongoDB uses "_id"
    let title: String
    let description: String
    let duration: String
    let budget: Int
    let price: Int?
    let skills: [String]
    let recruiterId: String
    let ownerId: String?
    let proposalsCount: Int?
    let interviewingCount: Int?
    let hasApplied: Bool?
    let isFavorite: Bool?
    let status: String?
    let paymentStatus: String?
    let assignedTalentId: String?
    let completedAt: String?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case _id
        case title
        case description
        case duration
        case budget
        case price
        case skills
        case recruiterId
        case ownerId
        case proposalsCount
        case interviewingCount
        case hasApplied
        case isFavorite
        case status
        case paymentStatus
        case assignedTalentId
        case completedAt
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
    
    private var resolvedBudget: Int {
        if let price {
            return price
        }
        return budget
    }
    
    /// Formatted budget string
    var formattedBudget: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        let value = resolvedBudget
        return "\(formatter.string(from: NSNumber(value: value)) ?? "\(value)") €"
    }
    
    var proposals: Int {
        proposalsCount ?? 0
    }
    
    var interviewing: Int {
        interviewingCount ?? 0
    }
    
    var ownerIdentifier: String {
        ownerId ?? recruiterId
    }
    
    var hasAppliedToMission: Bool {
        hasApplied ?? false
    }
    
    var isFavorited: Bool {
        isFavorite ?? false
    }
    
    var missionStatus: MissionStatus {
        guard let status = status else { return .inProgress }
        return MissionStatus(rawValue: status) ?? .inProgress
    }
}

enum MissionStatus: String, Codable {
    case inProgress = "in_progress"
    case started = "started"
    case completed = "completed"
    case paid = "paid"
    
    var displayName: String {
        switch self {
        case .inProgress: return "En cours"
        case .started: return "Démarrée"
        case .completed: return "Terminée"
        case .paid: return "Payée"
        }
    }
}


struct ApproveCompletionResponse: Codable {
    let mission: MissionModel
    let transaction: TransactionModel?
}

struct TransactionModel: Codable {
    let id: String
    let amount: Int
    let currency: String
    let status: String
    let createdAt: String
}

