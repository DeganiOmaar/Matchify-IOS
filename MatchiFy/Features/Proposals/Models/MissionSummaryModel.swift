import Foundation

/// Lightweight model for mission selector dropdown
struct MissionSummaryModel: Codable, Identifiable, Hashable {
    private let rawId: String?
    private let mongoId: String?
    let title: String
    let createdAt: String?
    let unviewedCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case rawId = "id"
        case mongoId = "_id"
        case title
        case createdAt
        case unviewedCount
    }
    
    // Identifiable conformance
    var id: String {
        if let cleanId = rawId, !cleanId.isEmpty { return cleanId }
        if let cleanMongoId = mongoId, !cleanMongoId.isEmpty { return cleanMongoId }
        return UUID().uuidString
    }
    
    // Helper for consistency
    var missionId: String {
        id
    }
    
    var formattedDate: String {
        guard let createdAt = createdAt else { return "" }
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = iso.date(from: createdAt) {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter.string(from: date)
        }
        return ""
    }
}
