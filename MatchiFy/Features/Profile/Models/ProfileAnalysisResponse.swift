import Foundation

struct ProfileAnalysisResponse: Codable {
    let summary: String
    let keyStrengths: [String]
    let areasToImprove: [String]
    let recommendedTags: [String]
    let profileScore: Int
    let analyzedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case summary
        case keyStrengths
        case areasToImprove
        case recommendedTags
        case profileScore
        case analyzedAt
    }
    
    var analyzedDate: Date? {
        guard let analyzedAt = analyzedAt else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: analyzedAt)
    }
}




