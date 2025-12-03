import Foundation

struct UpdateProposalStatusRequest: Codable {
    let status: ProposalStatus
    let rejectionReason: String?
}

