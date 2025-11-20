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
    
    func getTalentProposals() async throws -> [ProposalModel] {
        try await ApiClient.shared.get(
            url: Endpoints.proposalsTalent,
            requiresAuth: true
        )
    }
    
    func getRecruiterProposals() async throws -> [ProposalModel] {
        try await ApiClient.shared.get(
            url: Endpoints.proposalsRecruiter,
            requiresAuth: true
        )
    }
}

