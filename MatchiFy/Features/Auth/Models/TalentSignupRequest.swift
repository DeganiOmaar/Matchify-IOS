import Foundation

struct TalentSignupRequest: Codable {
    let fullName: String
    let email: String
    let password: String
    let confirmPassword: String
    let phone: String
    let profileImage: String?
    
    // Custom encoding to exclude profileImage if it's nil or empty
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fullName, forKey: .fullName)
        try container.encode(email, forKey: .email)
        try container.encode(password, forKey: .password)
        try container.encode(confirmPassword, forKey: .confirmPassword)
        try container.encode(phone, forKey: .phone)
        
        // Only encode profileImage if it's not nil and not empty
        if let profileImage = profileImage, !profileImage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            try container.encode(profileImage, forKey: .profileImage)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case fullName
        case email
        case password
        case confirmPassword
        case phone
        case profileImage
    }
}

