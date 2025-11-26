import Foundation

final class ProposalService {
    static let shared = ProposalService()
    private init() {}
    
    func createProposal(_ request: CreateProposalRequest) async throws -> ProposalModel {
        try await ApiClient.shared.post(
            url: Endpoints.proposals,
            body: request,
            requiresAuth: true
        )
    }
    
    func getTalentProposals(status: String? = nil, archived: Bool? = nil) async throws -> [ProposalModel] {
        var url = Endpoints.proposalsTalent
        var queryItems: [String] = []
        if let status = status {
            queryItems.append("status=\(status)")
        }
        if let archived = archived {
            queryItems.append("archived=\(archived)")
        }
        if !queryItems.isEmpty {
            url += "?" + queryItems.joined(separator: "&")
        }
        return try await ApiClient.shared.get(
            url: url,
            requiresAuth: true
        )
    }
    
    func getRecruiterProposals() async throws -> [ProposalModel] {
        try await ApiClient.shared.get(
            url: Endpoints.proposalsRecruiter,
            requiresAuth: true
        )
    }
    
    /// Get missions created by the authenticated recruiter
    /// Used for the mission selector dropdown
    func getRecruiterMissions() async throws -> [MissionSummaryModel] {
        try await ApiClient.shared.get(
            url: Endpoints.apiBase + "/recruiter/missions",
            requiresAuth: true
        )
    }
    
    func getProposal(id: String) async throws -> ProposalModel {
        try await ApiClient.shared.get(
            url: Endpoints.proposal(id: id),
            requiresAuth: true
        )
    }
    
    func updateStatus(id: String, status: ProposalStatus) async throws -> ProposalModel {
        try await ApiClient.shared.patch(
            url: Endpoints.proposalStatus(id: id),
            body: UpdateProposalStatusRequest(status: status),
            requiresAuth: true
        )
    }
    
    func getUnreadCount() async throws -> Int {
        let response: UnreadProposalsCountResponse = try await ApiClient.shared.get(
            url: Endpoints.proposalsUnreadCount,
            requiresAuth: true
        )
        return response.count
    }
    
    func archiveProposal(id: String) async throws -> ProposalModel {
        try await ApiClient.shared.patch(
            url: Endpoints.proposalArchive(id: id),
            body: EmptyBody(),
            requiresAuth: true
        )
    }
    
    func deleteProposal(id: String) async throws -> ProposalModel {
        try await ApiClient.shared.delete(
            url: Endpoints.proposal(id: id),
            requiresAuth: true
        )
    }
    
    func getRecruiterProposalsGrouped() async throws -> [String: [ProposalModel]] {
        try await ApiClient.shared.get(
            url: Endpoints.proposalsRecruiterGrouped,
            requiresAuth: true
        )
    }
    
    func generateProposalContent(missionId: String) async throws -> String {
        let request = GenerateProposalRequest(missionId: missionId)
        let response: GenerateProposalResponse = try await ApiClient.shared.post(
            url: Endpoints.aiProposalGenerate,
            body: request,
            requiresAuth: true
        )
        return response.proposalContent
    }
    
    // MARK: - AI-Powered Proposal Ranking
    
    /// Get proposals for a specific mission with optional AI sorting
    /// - Parameters:
    ///   - missionId: ID of the mission
    ///   - aiSort: Whether to sort by AI compatibility score
    /// - Returns: Mission with its proposals
    func getProposalsForMission(missionId: String, aiSort: Bool = false) async throws -> MissionProposalsResponse {
        var url = Endpoints.apiBase + "/recruiter/proposals/mission/\(missionId)"
        if aiSort {
            url += "?sort=ai"
        }
        return try await ApiClient.shared.get(
            url: url,
            requiresAuth: true
        )
    }
    
    /// Search proposals by mission title
    /// - Parameter title: Search query for mission title
    /// - Returns: Array of missions with their proposals
    func searchProposalsByMissionTitle(_ title: String) async throws -> [MissionProposalsSearchResult] {
        let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? title
        let url = Endpoints.apiBase + "/recruiter/proposals?title=\(encodedTitle)"
        return try await ApiClient.shared.get(
            url: url,
            requiresAuth: true
        )
    }
}

struct GenerateProposalRequest: Codable {
    let missionId: String
}

struct GenerateProposalResponse: Codable {
    let proposalContent: String
}

struct UnreadProposalsCountResponse: Codable {
    let count: Int
}

// MARK: - AI Proposal Ranking Models

struct MissionProposalsResponse: Codable {
    let mission: MissionModel
    let proposals: [ProposalModel]
}

struct MissionProposalsSearchResult: Codable {
    let mission: MissionModel
    let proposalCount: Int
    let proposals: [ProposalModel]
}
