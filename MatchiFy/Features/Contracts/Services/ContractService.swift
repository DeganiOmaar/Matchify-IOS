import Foundation

final class ContractService {
    static let shared = ContractService()
    private init() {}
    
    func createContract(_ request: CreateContractRequest) async throws -> ContractModel {
        try await ApiClient.shared.post(
            url: Endpoints.contracts,
            body: request,
            requiresAuth: true
        )
    }
    
    func getContract(id: String) async throws -> ContractModel {
        try await ApiClient.shared.get(
            url: Endpoints.contract(id: id),
            requiresAuth: true
        )
    }
    
    func getContractsByConversation(conversationId: String) async throws -> [ContractModel] {
        try await ApiClient.shared.get(
            url: Endpoints.contractsByConversation(conversationId: conversationId),
            requiresAuth: true
        )
    }
    
    func signContract(id: String, request: SignContractRequest) async throws -> ContractModel {
        try await ApiClient.shared.patch(
            url: Endpoints.contractSign(id: id),
            body: request,
            requiresAuth: true
        )
    }
    
    func declineContract(id: String) async throws -> ContractModel {
        try await ApiClient.shared.patch(
            url: Endpoints.contractDecline(id: id),
            body: EmptyBody(),
            requiresAuth: true
        )
    }
}

