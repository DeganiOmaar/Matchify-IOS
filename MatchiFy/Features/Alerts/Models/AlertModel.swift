import Foundation

enum AlertType: String, Codable {
    case proposalSubmitted = "PROPOSAL_SUBMITTED"
    case proposalAccepted = "PROPOSAL_ACCEPTED"
    case proposalRefused = "PROPOSAL_REFUSED"
    
    var displayIcon: String {
        switch self {
        case .proposalSubmitted: return "doc.text.fill"
        case .proposalAccepted: return "checkmark.circle.fill"
        case .proposalRefused: return "xmark.circle.fill"
        }
    }
}

struct AlertModel: Codable, Identifiable, Hashable {
    let id: String
    let _id: String?
    let userId: String
    let type: AlertType
    let missionId: String
    let proposalId: String
    let title: String
    let message: String
    let isRead: Bool
    let talentId: String?
    let talentName: String?
    let talentProfileImage: String?
    let recruiterId: String?
    let recruiterName: String?
    let recruiterProfileImage: String?
    let missionTitle: String?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case _id
        case userId
        case type
        case missionId
        case proposalId
        case title
        case message
        case isRead
        case talentId
        case talentName
        case talentProfileImage
        case recruiterId
        case recruiterName
        case recruiterProfileImage
        case missionTitle
        case createdAt
        case updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decodeIfPresent(String.self, forKey: ._id)
        let decodedId = try container.decodeIfPresent(String.self, forKey: .id)
        id = _id ?? decodedId ?? UUID().uuidString
        userId = try container.decode(String.self, forKey: .userId)
        type = try container.decode(AlertType.self, forKey: .type)
        missionId = try container.decode(String.self, forKey: .missionId)
        proposalId = try container.decode(String.self, forKey: .proposalId)
        title = try container.decode(String.self, forKey: .title)
        message = try container.decode(String.self, forKey: .message)
        isRead = try container.decode(Bool.self, forKey: .isRead)
        talentId = try container.decodeIfPresent(String.self, forKey: .talentId)
        talentName = try container.decodeIfPresent(String.self, forKey: .talentName)
        talentProfileImage = try container.decodeIfPresent(String.self, forKey: .talentProfileImage)
        recruiterId = try container.decodeIfPresent(String.self, forKey: .recruiterId)
        recruiterName = try container.decodeIfPresent(String.self, forKey: .recruiterName)
        recruiterProfileImage = try container.decodeIfPresent(String.self, forKey: .recruiterProfileImage)
        missionTitle = try container.decodeIfPresent(String.self, forKey: .missionTitle)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
    }
    
    var alertId: String {
        return id
    }
    
    var profileImageUrl: String? {
        if let talentImage = talentProfileImage, !talentImage.isEmpty {
            return talentImage
        }
        if let recruiterImage = recruiterProfileImage, !recruiterImage.isEmpty {
            return recruiterImage
        }
        return nil
    }
    
    var userName: String? {
        if let name = talentName, !name.isEmpty {
            return name
        }
        if let name = recruiterName, !name.isEmpty {
            return name
        }
        return nil
    }
    
    var formattedDate: String {
        guard let createdAt else { return "" }
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = iso.date(from: createdAt) {
            let now = Date()
            let calendar = Calendar.current
            let components = calendar.dateComponents([.minute, .hour, .day], from: date, to: now)
            
            if let days = components.day, days > 0 {
                if days == 1 {
                    return "Yesterday"
                } else if days < 7 {
                    return "\(days) days ago"
                } else {
                    let formatter = DateFormatter()
                    formatter.dateStyle = .medium
                    formatter.timeStyle = .none
                    return formatter.string(from: date)
                }
            } else if let hours = components.hour, hours > 0 {
                return "\(hours)h ago"
            } else if let minutes = components.minute, minutes > 0 {
                return "\(minutes)m ago"
            } else {
                return "Just now"
            }
        }
        return ""
    }
}

struct AlertsResponse: Codable {
    let alerts: [AlertModel]
    let total: Int
    let page: Int
    let limit: Int
}

struct UnreadCountResponse: Codable {
    let count: Int
}

struct MarkReadResponse: Codable {
    let _id: String
    let isRead: Bool
}

struct MarkAllReadResponse: Codable {
    let count: Int
}

