import Foundation

class WalletService {
    static let shared = WalletService()
    
    private init() {}
    
    // MARK: - Wallet Summary
    
    func getWalletSummary() async throws -> WalletSummaryModel {
        let endpoint = Endpoints.apiBase + "/wallet/summary"
        return try await ApiClient.shared.get(
            url: endpoint,
            requiresAuth: true
        )
    }
    
    // MARK: - Transactions
    
    func getTransactions(page: Int = 1, limit: Int = 20, status: String? = nil) async throws -> TransactionListResponse {
        var endpoint = Endpoints.apiBase + "/wallet/transactions?page=\(page)&limit=\(limit)"
        if let status = status {
            endpoint += "&status=\(status)"
        }
        return try await ApiClient.shared.get(
            url: endpoint,
            requiresAuth: true
        )
    }
    
    func getTransactionDetails(id: String) async throws -> PaymentTransactionModel {
        let endpoint = Endpoints.apiBase + "/wallet/transactions/\(id)"
        return try await ApiClient.shared.get(
            url: endpoint,
            requiresAuth: true
        )
    }
    
    // MARK: - Payment Methods (Recruiter)
    
    func getPaymentMethods() async throws -> [PaymentMethodModel] {
        let endpoint = Endpoints.apiBase + "/wallet/payment-methods"
        return try await ApiClient.shared.get(
            url: endpoint,
            requiresAuth: true
        )
    }
    
    func addPaymentMethod(paymentMethodId: String) async throws -> PaymentMethodModel {
        let endpoint = Endpoints.apiBase + "/wallet/payment-methods"
        struct AddPaymentMethodRequest: Codable {
            let paymentMethodId: String
        }
        return try await ApiClient.shared.post(
            url: endpoint,
            body: AddPaymentMethodRequest(paymentMethodId: paymentMethodId),
            requiresAuth: true
        )
    }
    
    func setDefaultPaymentMethod(paymentMethodId: String) async throws {
        let endpoint = Endpoints.apiBase + "/wallet/payment-methods/\(paymentMethodId)/default"
        let _: EmptyBody? = try await ApiClient.shared.put(
            url: endpoint,
            body: EmptyBody(),
            requiresAuth: true
        )
    }
    
    func removePaymentMethod(paymentMethodId: String) async throws {
        let endpoint = Endpoints.apiBase + "/wallet/payment-methods/\(paymentMethodId)"
        let _: EmptyBody? = try await ApiClient.shared.delete(
            url: endpoint,
            requiresAuth: true
        )
    }
    
    // MARK: - Payout (Talent)
    
    func getPayoutStatus() async throws -> PayoutStatusResponse {
        let endpoint = Endpoints.apiBase + "/wallet/payout-status"
        return try await ApiClient.shared.get(
            url: endpoint,
            requiresAuth: true
        )
    }
    
    func requestPayout(amount: Double) async throws {
        let endpoint = Endpoints.apiBase + "/wallet/payout"
        struct RequestPayoutRequest: Codable {
            let amount: Double
        }
        let _: EmptyBody? = try await ApiClient.shared.post(
            url: endpoint,
            body: RequestPayoutRequest(amount: amount),
            requiresAuth: true
        )
    }
}

// MARK: - Helper Models

// EmptyResponse removed as it is handled elsewhere
