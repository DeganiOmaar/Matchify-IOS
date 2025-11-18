import Foundation

struct UserModel: Codable {
    let id: String?            // Sometimes backend uses "id"
    let _id: String?           // MongoDB uses "_id"
    let fullName: String
    let email: String
    let role: String
    let phone: String?
    let profileImage: String?
    let location: String?
    let talent: [String]?
    let createdAt: String?
    let updatedAt: String?
    let description: String?
    let skills: [String]?
    let portfolioLink: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case _id
        case fullName
        case email
        case role
        case phone
        case profileImage
        case location
        case talent
        case createdAt
        case updatedAt
        case description
        case skills
        case portfolioLink
    }
    
    /// URL complète de la photo de profil (ton backend renvoie un chemin relatif type "uploads/profile/xxx.jpg")
    var profileImageURL: URL? {
        // Return nil if profileImage is nil, empty, or blank
        guard var path = profileImage?.trimmingCharacters(in: .whitespacesAndNewlines),
              !path.isEmpty else {
            return nil
        }

        // Si le backend ne renvoie PAS de slash, on l'ajoute
        // Example: "uploads/profile/image.jpg" -> "/uploads/profile/image.jpg"
        if !path.hasPrefix("/") {
            path = "/" + path
        }

        // Use Endpoints.baseURL for dynamic base URL
        let fullUrlString = Endpoints.baseURL + path
        
        // Debug log
        print("📸 Profile image URL: \(fullUrlString) (from path: \(profileImage ?? "nil"))")

        return URL(string: fullUrlString)
    }   
}

