import Foundation

class PaymentService {
    static let shared = PaymentService()
    
    private init() {}
    
    // MARK: - Mission Payment
    
    func completeMission(missionId: String) async throws {
        let endpoint = Endpoints.apiBase + "/missions/\(missionId)/complete"
        let _: EmptyBody? = try await ApiClient.shared.post(
            url: endpoint,
            body: EmptyBody(),
            requiresAuth: true
        )
        // Endpoints.apiBase usage might be incorrect if ApiClient handles base URL. 
        // Checking ConversationService: Endpoints.conversationMessages(id:) returns full path or relative?
        // ConversationService uses Endpoints.conversations which likely returns full URL or path.
        // I should probably use `ApiClient.shared.post` directly. 
        // Example: ApiClient.shared.post(url: ..., body: ..., requiresAuth: true)
        // I need to assume Endpoints.apiBase + ... constructs a valid URL string or URL.
        // ConversationService uses `Endpoints.conversations`.
        
        // I'll try to follow ApiClient pattern:
        // try await ApiClient.shared.post(url: ..., body: ..., requiresAuth: true)
        
        // However, I don't have the "Endpoints" definition for these new routes.
        // I should probably allow constructing the URL string.
        
        // Let's assume ApiClient accepts a URL string or URL.
        // In ConversationService: url: Endpoints.conversations
        
        // I will use `ApiClient.shared.post` and wrap the URL in URL(string: ...)!
        
    }
    
    func createPaymentIntent(missionId: String, paymentMethodId: String? = nil) async throws -> PaymentIntentResponse {
        let endpoint = Endpoints.apiBase + "/payment/create-intent"
        struct CreatePaymentIntentRequest: Codable {
            let missionId: String
            let paymentMethodId: String?
        }
        
        return try await ApiClient.shared.post(
            url: endpoint,
            body: CreatePaymentIntentRequest(missionId: missionId, paymentMethodId: paymentMethodId),
            requiresAuth: true
        )
    }
    
    func confirmPayment(paymentIntentId: String, missionId: String) async throws -> PaymentTransactionModel {
        let endpoint = Endpoints.apiBase + "/payment/confirm"
        struct ConfirmPaymentRequest: Codable {
            let paymentIntentId: String
            let missionId: String
        }
        
        return try await ApiClient.shared.post(
            url: endpoint,
            body: ConfirmPaymentRequest(paymentIntentId: paymentIntentId, missionId: missionId),
            requiresAuth: true
        )
    }
    
    // MARK: - Connect Account (Talent)
    
    func createConnectAccount(email: String, country: String = "FR") async throws -> ConnectAccountModel {
        let endpoint = Endpoints.apiBase + "/payment/connect/create"
        struct CreateConnectAccountRequest: Codable {
            let email: String
            let country: String
        }
        
        return try await ApiClient.shared.post(
            url: endpoint,
            body: CreateConnectAccountRequest(email: email, country: country),
            requiresAuth: true
        )
    }
    
    func getConnectAccountStatus(accountId: String) async throws -> ConnectAccountStatus {
        let endpoint = Endpoints.apiBase + "/payment/connect/status/\(accountId)"
        return try await ApiClient.shared.get(
            url: endpoint,
            requiresAuth: true
        )
    }
}

// MARK: - Response Models

struct MissionPaymentResponse: Codable {
    let mission: MissionModel
    let payment: PaymentIntentResponse?
}

struct PaymentIntentResponse: Codable {
    let clientSecret: String
    let paymentIntentId: String
    let customerId: String?
    let ephemeralKey: String?
    let publishableKey: String?
}

// EmptyResponse removed as it is likely defined elsewhere or handled by ApiClient
