import Foundation

struct ConversationModel: Codable, Identifiable, Hashable {
    let id: String?
    let _id: String?
    let missionId: String?
    let recruiterId: String
    let talentId: String
    let lastMessageText: String?
    let lastMessageAt: String?
    let createdAt: String?
    let updatedAt: String?
    
    // Talent information (for recruiter view)
    let talentName: String?
    let talentProfileImage: String?
    
    // Recruiter information (for talent view)
    let recruiterName: String?
    let recruiterProfileImage: String?
    
    // Unread count (not from backend, computed locally)
    // This is excluded from Codable and Hashable
    var unreadCount: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case id, _id, missionId, recruiterId, talentId
        case lastMessageText, lastMessageAt, createdAt, updatedAt
        case talentName, talentProfileImage
        case recruiterName, recruiterProfileImage
    }
    
    var conversationId: String {
        if let id, !id.isEmpty { return id }
        if let mongo = _id, !mongo.isEmpty { return mongo }
        return UUID().uuidString
    }
    
    var formattedLastMessageTime: String {
        guard let lastMessageAt = lastMessageAt else { return "" }
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = iso.date(from: lastMessageAt) {
            let now = Date()
            let timeInterval = now.timeIntervalSince(date)
            
            let minutes = Int(timeInterval / 60)
            let hours = Int(timeInterval / 3600)
            let days = Int(timeInterval / 86400)
            
            if minutes < 1 {
                return "Just now"
            } else if minutes < 60 {
                return "\(minutes)m ago"
            } else if hours < 24 {
                return "\(hours)h ago"
            } else if days < 7 {
                return "\(days)d ago"
            } else {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.timeStyle = .none
                return formatter.string(from: date)
            }
        }
        return ""
    }
    
    // Helper to get other user's name based on role
    func getOtherUserName(isRecruiter: Bool) -> String {
        if isRecruiter {
            return talentName ?? "Talent"
        } else {
            return recruiterName ?? "Recruiter"
        }
    }
    
    // Helper to get other user's profile image URL
    func getOtherUserProfileImageURL(isRecruiter: Bool) -> URL? {
        let imagePath: String?
        if isRecruiter {
            imagePath = talentProfileImage
        } else {
            imagePath = recruiterProfileImage
        }
        
        guard let path = imagePath?.trimmingCharacters(in: .whitespacesAndNewlines),
              !path.isEmpty else {
            return nil
        }
        
        let fullPath = path.hasPrefix("/") ? path : "/\(path)"
        return URL(string: Endpoints.baseURL + fullPath)
    }
    
    // Hashable implementation (exclude unreadCount)
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(_id)
        hasher.combine(missionId)
        hasher.combine(recruiterId)
        hasher.combine(talentId)
        hasher.combine(lastMessageText)
        hasher.combine(lastMessageAt)
        hasher.combine(createdAt)
        hasher.combine(updatedAt)
        hasher.combine(talentName)
        hasher.combine(talentProfileImage)
        hasher.combine(recruiterName)
        hasher.combine(recruiterProfileImage)
    }
    
    // Equatable implementation (exclude unreadCount)
    static func == (lhs: ConversationModel, rhs: ConversationModel) -> Bool {
        return lhs.id == rhs.id &&
               lhs._id == rhs._id &&
               lhs.missionId == rhs.missionId &&
               lhs.recruiterId == rhs.recruiterId &&
               lhs.talentId == rhs.talentId &&
               lhs.lastMessageText == rhs.lastMessageText &&
               lhs.lastMessageAt == rhs.lastMessageAt &&
               lhs.createdAt == rhs.createdAt &&
               lhs.updatedAt == rhs.updatedAt &&
               lhs.talentName == rhs.talentName &&
               lhs.talentProfileImage == rhs.talentProfileImage &&
               lhs.recruiterName == rhs.recruiterName &&
               lhs.recruiterProfileImage == rhs.recruiterProfileImage
    }
}

