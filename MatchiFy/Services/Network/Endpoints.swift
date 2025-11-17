import Foundation

struct Endpoints {
    static let baseURL = "http://172.16.6.156:3000"
    static let base = baseURL + "/auth"
    static let apiBase = baseURL

    static let login = base + "/login"
    static let signupTalent = base + "/signup/talent"
    static let signupRecruiter = base + "/signup/recruiter"
    // Password reset flow
    static let forgotPassword = base + "/password/forgot"
    static let verifyResetCode = base + "/password/verify"
    static let resetPassword = base + "/password/reset"
    
    // Missions endpoints
    static let missions = apiBase + "/missions"
    static let allMissions = apiBase + "/missions/all"
    static let missionStream = apiBase + "/missions/stream"
    static func mission(id: String) -> String {
        return apiBase + "/missions/\(id)"
    }
    
    // Profile endpoints
    static let recruiterProfile = apiBase + "/recruiter/profile"
    static let talentProfile = apiBase + "/talent/profile"
}
