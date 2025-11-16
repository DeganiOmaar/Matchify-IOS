import Foundation

// MARK: - Login Request
struct LoginRequest: Codable {
    let email: String
    let password: String
}

// MARK: - User Model (used everywhere)
struct UserModel: Codable {
    let id: String?            // Sometimes backend uses "id"
    let _id: String?           // MongoDB uses "_id"
    let fullName: String
    let email: String
    let role: String
    let phone: String?
    let profileImage: String?
    let location: String?
    let talent: String?
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

        // IP locale Mac
        let base = "http://192.168.1.102:3000"
        let fullUrlString = base + path
        
        // Debug log
        print("📸 Profile image URL: \(fullUrlString) (from path: \(profileImage ?? "nil"))")

        return URL(string: fullUrlString)
    }   
}

// MARK: - Login Response
struct LoginResponse: Codable {
    let message: String
    let token: String
    let role: String
    let user: UserModel
}

// MARK: - Talent Signup Request
struct TalentSignupRequest: Codable {
    let fullName: String
    let email: String
    let password: String
    let confirmPassword: String
    let phone: String
    let profileImage: String?
    let location: String
    let talent: String
    
    // Custom encoding to exclude profileImage if it's nil or empty
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fullName, forKey: .fullName)
        try container.encode(email, forKey: .email)
        try container.encode(password, forKey: .password)
        try container.encode(confirmPassword, forKey: .confirmPassword)
        try container.encode(phone, forKey: .phone)
        try container.encode(location, forKey: .location)
        try container.encode(talent, forKey: .talent)
        
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
        case location
        case talent
    }
}

// MARK: - Recruiter Signup Request
struct RecruiterSignupRequest: Codable {
    let fullName: String
    let email: String
    let password: String
    let confirmPassword: String
}

// MARK: - Talent Signup Response
struct TalentSignupResponse: Codable {
    let message: String?
    let user: UserModel
    let token: String
    let role: String?  // Optional for backward compatibility
}

// MARK: - Recruiter Signup Response
struct RecruiterSignupResponse: Codable {
    let message: String?
    let user: UserModel
    let token: String
    let role: String?  // Optional for backward compatibility
}

// MARK: - Forgot Password
struct ForgotPasswordRequest: Codable {
    let email: String
}

struct ForgotPasswordResponse: Codable {
    let message: String
    let expiresIn: String?
}

// MARK: - Verify Reset Code
struct VerifyResetCodeRequest: Codable {
    let code: String
}

struct VerifyResetCodeResponse: Codable {
    let message: String
    let verified: Bool
}

// MARK: - Reset Password
struct ResetPasswordRequest: Codable {
    let newPassword: String
    let confirmPassword: String
}

struct ResetPasswordResponse: Codable {
    let message: String
}

// MARK: - Update Recruiter Profile Response
struct UpdateRecruiterProfileResponse: Codable {
    let message: String
    let user: UserModel
}

// MARK: - Update Talent Profile Response
struct UpdateTalentProfileResponse: Codable {
    let message: String
    let user: UserModel
}
