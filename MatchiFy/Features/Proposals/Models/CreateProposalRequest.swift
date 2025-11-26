import Foundation

struct CreateProposalRequest: Codable {
    let missionId: String
    let message: String?
    let proposalContent: String
    let proposedBudget: Int?
    let estimatedDuration: String?
}

