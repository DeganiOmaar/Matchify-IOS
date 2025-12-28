import Foundation

// MARK: - Wallet Summary Model
struct WalletSummaryModel: Codable {
    let userId: String
    let role: String
    let availableBalance: Double
    let pendingBalance: Double
    let totalEarned: Double
    let totalSpent: Double
    let stripeCustomerId: String?
    let stripeConnectAccountId: String?
    
    enum CodingKeys: String, CodingKey {
        case userId
        case role
        case availableBalance
        case pendingBalance
        case totalEarned
        case totalSpent
        case stripeCustomerId
        case stripeConnectAccountId
    }
}

// MARK: - Transaction List Response
struct TransactionListResponse: Codable {
    let transactions: [PaymentTransactionModel]
    let total: Int
    let pages: Int
    
    enum CodingKeys: String, CodingKey {
        case transactions
        case total
        case pages
    }
}

// MARK: - Payout Model
struct PayoutModel: Codable {
    let id: String
    let amount: Double
    let status: String
    let arrivalDate: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case amount
        case status
        case arrivalDate
    }
}

// MARK: - Payout Status Response
struct PayoutStatusResponse: Codable {
    let hasConnectAccount: Bool
    let payouts: [PayoutModel]?
    
    enum CodingKeys: String, CodingKey {
        case hasConnectAccount
        case payouts
    }
}
