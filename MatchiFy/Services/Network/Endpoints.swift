import Foundation

struct Endpoints {
    static let baseURL = "http://192.168.1.186:3000"
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
    
    // Proposal endpoints
    static let proposals = apiBase + "/proposals"
    static let proposalsTalent = apiBase + "/proposals/talent"
    static let proposalsRecruiter = apiBase + "/proposals/recruiter"
    static func proposal(id: String) -> String {
        return apiBase + "/proposals/\(id)"
    }
    static func proposalStatus(id: String) -> String {
        return apiBase + "/proposals/\(id)/status"
    }
    static func proposalsMissionCount(_ missionId: String) -> String {
        return apiBase + "/proposals/mission/\(missionId)/count"
    }
    
    // Profile endpoints
    static let recruiterProfile = apiBase + "/recruiter/profile"
    static let talentProfile = apiBase + "/talent/profile"
    static func userById(_ id: String) -> String {
        return apiBase + "/user/\(id)"
    }
    
    // Portfolio endpoints
    static let portfolio = apiBase + "/talent/portfolio"
    static func portfolioProject(id: String) -> String {
        return apiBase + "/talent/portfolio/\(id)"
    }
    
    // Skills endpoints
    static let skillsSearch = apiBase + "/skills"
    static func skillsByIds(ids: [String]) -> String {
        let idsString = ids.joined(separator: ",")
        return apiBase + "/skills/by-ids?ids=\(idsString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
    }
    
    // Conversations endpoints
    static let conversations = apiBase + "/conversations"
    static func conversation(id: String) -> String {
        return apiBase + "/conversations/\(id)"
    }
    static func conversationMessages(id: String) -> String {
        return apiBase + "/conversations/\(id)/messages"
    }
}
