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
}

struct UnreadProposalsCountResponse: Codable {
    let count: Int
}
