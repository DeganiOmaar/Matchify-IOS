import Foundation

struct OfferModel: Codable, Identifiable, Hashable {
    let id: String?
    let _id: String?
    let category: String
    let title: String
    let keywords: [String]
    let price: Int
    let description: String
    let bannerImage: String
    let galleryImages: [String]?
    let introductionVideo: String?
    let capabilities: [String]?
    let talentId: String
    let dateOfPosting: String?
    let createdAt: String?
    let updatedAt: String?
    let reviews: [ReviewModel]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case _id
        case category
        case title
        case keywords
        case price
        case description
        case bannerImage
        case galleryImages
        case introductionVideo
        case capabilities
        case talentId
        case dateOfPosting
        case createdAt
        case updatedAt
        case reviews
    }
    
    /// Get the offer ID (handles both id and _id)
    var offerId: String {
        if let cleanId = id, !cleanId.isEmpty { return cleanId }
        if let cleanMongoId = _id, !cleanMongoId.isEmpty { return cleanMongoId }
        if let createdAt = createdAt, !createdAt.isEmpty { return createdAt }
        return UUID().uuidString
    }
    
    /// Formatted date string for display
    var formattedDate: String {
        guard let dateString = dateOfPosting ?? createdAt else { return "-" }
        
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = iso.date(from: dateString) {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "fr_FR")
            formatter.dateFormat = "dd MMM yyyy"
            return formatter.string(from: date)
        }
        
        return "-"
    }
    
    /// Formatted price string
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        return "\(formatter.string(from: NSNumber(value: price)) ?? "\(price)") €"
    }
    
    /// Gallery images array (never nil)
    var gallery: [String] {
        galleryImages ?? []
    }
    
    /// Capabilities array (never nil)
    var capabilitiesList: [String] {
        capabilities ?? []
    }
    
    /// Reviews array (never nil)
    var reviewsList: [ReviewModel] {
        reviews ?? []
    }
    
    /// Has introduction video
    var hasVideo: Bool {
        introductionVideo != nil && !(introductionVideo?.isEmpty ?? true)
    }
}

struct ReviewModel: Codable, Hashable, Identifiable {
    var id: String { recruiterId + (createdAt ?? "") }
    let recruiterId: String
    let recruiterName: String
    let rating: Int
    let message: String
    let createdAt: String?
}

enum OfferCategory: String, CaseIterable, Codable {
    case development = "Development"
    case marketing = "Marketing"
    case teachingOnline = "Teaching Online"
    case videoEditing = "Video Editing"
    case coaching = "Coaching"
    
    var displayName: String {
        rawValue
    }
    
    var iconName: String {
        switch self {
        case .development: return "chevron.left.forwardslash.chevron.right"
        case .marketing: return "megaphone.fill"
        case .teachingOnline: return "book.fill"
        case .videoEditing: return "film.fill"
        case .coaching: return "person.2.fill"
        }
    }
}
