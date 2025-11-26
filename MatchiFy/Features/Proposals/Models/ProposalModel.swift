import Foundation
import SwiftUI

enum ProposalStatus: String, Codable {
    case notViewed = "NOT_VIEWED"
    case viewed = "VIEWED"
    case accepted = "ACCEPTED"
    case refused = "REFUSED"
    
    var displayName: String {
        switch self {
        case .notViewed: return "Not viewed"
        case .viewed: return "Viewed"
        case .accepted: return "Accepted"
        case .refused: return "Refused"
        }
    }
}

struct ProposalModel: Codable, Identifiable, Hashable {
    let id: String?
    let _id: String?
    let missionId: String
    let missionTitle: String?
    let talentId: String
    let talentName: String?
    let talent: TalentInfo? // Nested talent object from backend
    let recruiterId: String
    let recruiterName: String?
    let status: ProposalStatus
    let message: String
    let proposalContent: String?
    let proposedBudget: Int?
    let estimatedDuration: String?
    let archived: Bool?
    let createdAt: String?
    let updatedAt: String?
    let aiScore: Int? // AI compatibility score (0-100)
    
    enum CodingKeys: String, CodingKey {
        case id
        case _id
        case missionId
        case missionTitle
        case talentId
        case talentName
        case talent
        case recruiterId
        case recruiterName
        case status
        case message
        case proposalContent
        case proposedBudget
        case estimatedDuration
        case archived
        case createdAt
        case updatedAt
        case aiScore
    }
    
    // Helper to get talent full name from either direct field or nested object
    // Prioritize nested talent.fullName over talentName (which might contain email)
    // NEVER return an email address - always return a name or nil
    var talentFullName: String? {
        // First check nested talent object for fullName (most reliable)
        if let nestedFullName = talent?.fullName, !nestedFullName.isEmpty, !nestedFullName.contains("@") {
            return nestedFullName
        }
        // Then check talentName, but only if it doesn't look like an email
        // talentName might contain email if fullName wasn't available when proposal was created
        if let name = talentName, !name.isEmpty {
            // If it contains @, it's an email, so ignore it completely
            if name.contains("@") {
                return nil
            }
            return name
        }
        return nil
    }
    
    var proposalId: String {
        if let id, !id.isEmpty { return id }
        if let mongo = _id, !mongo.isEmpty { return mongo }
        return UUID().uuidString
    }
    
    var formattedDate: String {
        guard let createdAt else { return "-" }
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = iso.date(from: createdAt) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        return "-"
    }
    
    var isArchived: Bool {
        archived ?? false
    }
    
    // AI Score display properties
    var aiScoreColor: Color {
        guard let score = aiScore else { return .gray }
        if score >= 80 {
            return .green
        } else if score >= 50 {
            return .orange
        } else {
            return .red
        }
    }
    
    var aiScoreText: String {
        guard let score = aiScore else { return "N/A" }
        return "\(score)/100"
    }
    
    var hasAiScore: Bool {
        aiScore != nil
    }
}

// Helper struct for nested talent object
struct TalentInfo: Codable, Equatable, Hashable {
    let fullName: String?
    let email: String?
    
    enum CodingKeys: String, CodingKey {
        case fullName
        case email
    }
}

