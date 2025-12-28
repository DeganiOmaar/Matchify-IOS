import Foundation

// MARK: - Payment Intent Model
struct PaymentIntentModel: Codable {
    let id: String
    let clientSecret: String
    let amount: Double
    let status: PaymentStatus
    
    enum CodingKeys: String, CodingKey {
        case id
        case clientSecret
        case amount
        case status
    }
}

// MARK: - Payment Status
enum PaymentStatus: String, Codable {
    case pending
    case processing
    case completed
    case failed
    case refunded
}

// MARK: - Payment Method Model
struct PaymentMethodModel: Codable {
    let id: String
    let type: String
    let last4: String?
    let brand: String?
    let isDefault: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case last4
        case brand
        case isDefault
    }
}

// MARK: - Payment Transaction Model
struct PaymentTransactionModel: Codable {
    let id: String
    let missionId: String
    let amount: Double
    let platformFee: Double
    let talentAmount: Double
    let status: PaymentStatus
    let direction: TransactionDirection
    let createdAt: Date
    let completedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case missionId
        case amount
        case platformFee
        case talentAmount
        case status
        case direction
        case createdAt
        case completedAt
    }
}

// MARK: - Transaction Direction
enum TransactionDirection: String, Codable {
    case `in` = "in"
    case out = "out"
}

// MARK: - Connect Account Model
struct ConnectAccountModel: Codable {
    let accountId: String
    let onboardingUrl: String
    
    enum CodingKeys: String, CodingKey {
        case accountId
        case onboardingUrl
    }
}

// MARK: - Connect Account Status
struct ConnectAccountStatus: Codable {
    let verified: Bool
    let chargesEnabled: Bool
    let payoutsEnabled: Bool
    
    enum CodingKeys: String, CodingKey {
        case verified
        case chargesEnabled
        case payoutsEnabled
    }
}
