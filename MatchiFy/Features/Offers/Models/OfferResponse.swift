import Foundation

struct CreateOfferRequest: Codable {
    let category: String
    let title: String
    let keywords: [String]
    let price: Int
    let description: String
    let capabilities: [String]?
}

struct OfferResponse: Codable {
    let offer: OfferModel
}

struct OffersResponse: Codable {
    let offers: [OfferModel]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        offers = try container.decode([OfferModel].self)
    }
}
