import Foundation

struct TalentStatsResponse: Codable {
    let totalProposalsSent: Int
    let totalProposalsAccepted: Int
    let totalProposalsRefused: Int
    let totalEarnings: Double
}

final class StatsService {
    static let shared = StatsService()
    private init() {}
    
    // MARK: - Get Talent Stats
    func getTalentStats(days: Int) async throws -> TalentStatsResponse {
        return try await ApiClient.shared.get(
            url: Endpoints.talentStats(days: days),
            requiresAuth: true
        )
    }
}

