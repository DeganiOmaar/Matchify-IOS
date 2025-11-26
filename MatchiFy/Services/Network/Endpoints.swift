import Foundation

struct Endpoints {
    static let baseURL = "http://192.168.1.102:3000"
    static let base = baseURL + "/auth"
    static let apiBase = baseURL

    static let login = base + "/login"
    static let signupTalent = base + "/signup/talent"
    static let signupRecruiter = base + "/signup/recruiter"
    static let logout = base + "/logout"
    // Password reset flow
    static let forgotPassword = base + "/password/forgot"
    static let verifyResetCode = base + "/password/verify"
    static let resetPassword = base + "/password/reset"
    
    // Missions endpoints
    static let missions = apiBase + "/missions"
    static let allMissions = apiBase + "/missions/all"
    static let bestMatchMissions = apiBase + "/missions/best-match"
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
    static let talentUploadCv = apiBase + "/talent/upload-cv"
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
    static let conversationsUnreadCount = apiBase + "/conversations/unread-count"
    static let conversationsWithUnread = apiBase + "/conversations/conversations-with-unread"
    static func conversation(id: String) -> String {
        return apiBase + "/conversations/\(id)"
    }
    static func conversationMessages(id: String) -> String {
        return apiBase + "/conversations/\(id)/messages"
    }
    static func conversationUnreadCount(id: String) -> String {
        return apiBase + "/conversations/\(id)/unread-count"
    }
    static func conversationMarkRead(id: String) -> String {
        return apiBase + "/conversations/\(id)/mark-read"
    }
    static func conversationDelete(id: String) -> String {
        return apiBase + "/conversations/\(id)"
    }
    
    // Favorites endpoints
    static let favorites = apiBase + "/favorites"
    static func favorite(missionId: String) -> String {
        return apiBase + "/favorites/\(missionId)"
    }
    
    // Alerts endpoints
    static let alerts = apiBase + "/alerts"
    static let alertsUnreadCount = apiBase + "/alerts/unread-count"
    static func alert(id: String) -> String {
        return apiBase + "/alerts/\(id)"
    }
    static func alertMarkRead(id: String) -> String {
        return apiBase + "/alerts/\(id)/read"
    }
    static let alertsMarkAllRead = apiBase + "/alerts/read-all"
    
    // Proposals unread count (for recruiter)
    static let proposalsUnreadCount = apiBase + "/proposals/recruiter/unread-count"
    static func proposalArchive(id: String) -> String {
        return apiBase + "/proposals/\(id)/archive"
    }
    static let proposalsRecruiterGrouped = apiBase + "/proposals/recruiter/grouped"
    
    // Contract endpoints
    static let contracts = apiBase + "/contracts"
    static func contract(id: String) -> String {
        return apiBase + "/contracts/\(id)"
    }
    static func contractSign(id: String) -> String {
        return apiBase + "/contracts/\(id)/sign"
    }
    static func contractDecline(id: String) -> String {
        return apiBase + "/contracts/\(id)/decline"
    }
    static func contractsByConversation(conversationId: String) -> String {
        return apiBase + "/contracts/conversation/\(conversationId)"
    }
    
    // Stats endpoints
    static func talentStats(days: Int) -> String {
        return apiBase + "/talent/stats?days=\(days)"
    }
    
    // AI endpoints
    static let aiProfileAnalysis = apiBase + "/ai/profile-analysis"
    static let aiProfileAnalysisLatest = apiBase + "/ai/profile-analysis"
    static func aiMissionFit(missionId: String) -> String {
        return apiBase + "/ai/mission-fit/\(missionId)"
    }
    static let aiProposalGenerate = apiBase + "/ai/proposals/generate"
}
