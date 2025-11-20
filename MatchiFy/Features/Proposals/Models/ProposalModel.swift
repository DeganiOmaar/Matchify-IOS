import Foundation

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

struct ProposalModel: Codable, Identifiable {
    let id: String?
    let _id: String?
    let missionId: String
    let missionTitle: String?
    let talentId: String
    let talentName: String?
    let recruiterId: String
    let status: ProposalStatus
    let message: String
    let proposedBudget: Int?
    let estimatedDuration: String?
    let createdAt: String?
    let updatedAt: String?
    
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
}

