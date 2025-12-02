import Foundation

final class ProposalService {
    static let shared = ProposalService()
    private init() {}
    
    func createProposal(_ request: CreateProposalRequest) async throws -> ProposalModel {
        try await ApiClient.shared.post(
            url: Endpoints.proposals,
            body: request,
            requiresAuth: true
        )
    }
    
    func getTalentProposals(status: String? = nil, archived: Bool? = nil) async throws -> [ProposalModel] {
        var url = Endpoints.proposalsTalent
        var queryItems: [String] = []
        if let status = status {
            queryItems.append("status=\(status)")
        }
        if let archived = archived {
            queryItems.append("archived=\(archived)")
        }
        if !queryItems.isEmpty {
            url += "?" + queryItems.joined(separator: "&")
        }
        return try await ApiClient.shared.get(
            url: url,
            requiresAuth: true
        )
    }
    
    func getRecruiterProposals() async throws -> [ProposalModel] {
        try await ApiClient.shared.get(
            url: Endpoints.proposalsRecruiter,
            requiresAuth: true
        )
    }
    
    /// Get missions created by the authenticated recruiter
    /// Used for the mission selector dropdown
    func getRecruiterMissions() async throws -> [MissionSummaryModel] {
        try await ApiClient.shared.get(
            url: Endpoints.apiBase + "/recruiter/missions",
            requiresAuth: true
        )
    }
    
    func getProposal(id: String) async throws -> ProposalModel {
        try await ApiClient.shared.get(
            url: Endpoints.proposal(id: id),
            requiresAuth: true
        )
    }
    
    func updateStatus(id: String, status: ProposalStatus) async throws -> ProposalModel {
        try await ApiClient.shared.patch(
            url: Endpoints.proposalStatus(id: id),
            body: UpdateProposalStatusRequest(status: status),
            requiresAuth: true
        )
    }
    
    func getUnreadCount() async throws -> Int {
        let response: UnreadProposalsCountResponse = try await ApiClient.shared.get(
            url: Endpoints.proposalsUnreadCount,
            requiresAuth: true
        )
        return response.count
    }
    
    func archiveProposal(id: String) async throws -> ProposalModel {
        try await ApiClient.shared.patch(
            url: Endpoints.proposalArchive(id: id),
            body: EmptyBody(),
            requiresAuth: true
        )
    }
    
    func deleteProposal(id: String) async throws -> ProposalModel {
        try await ApiClient.shared.delete(
            url: Endpoints.proposal(id: id),
            requiresAuth: true
        )
    }
    
    func getRecruiterProposalsGrouped() async throws -> [String: [ProposalModel]] {
        try await ApiClient.shared.get(
            url: Endpoints.proposalsRecruiterGrouped,
            requiresAuth: true
        )
    }
    
    func generateProposalContent(missionId: String) async throws -> String {
        let request = GenerateProposalRequest(missionId: missionId)
        let response: GenerateProposalResponse = try await ApiClient.shared.post(
            url: Endpoints.aiProposalGenerate,
            body: request,
            requiresAuth: true
        )
        return response.proposalContent
    }
    
    /// Generate proposal content with real-time streaming
    /// - Parameter missionId: The ID of the mission
    /// - Returns: AsyncStream of proposal text chunks
    func generateProposalContentStream(missionId: String) -> AsyncStream<String> {
        return AsyncStream { continuation in
            Task {
                print("🔵 [STREAMING] Starting proposal generation for mission: \(missionId)")
                
                // Get auth token from AuthManager (not UserDefaults!)
                guard let token = AuthManager.shared.token else {
                    print("❌ [STREAMING] No auth token found in AuthManager")
                    continuation.finish()
                    return
                }
                
                print("✅ [STREAMING] Auth token found: \(token.prefix(20))...")
                
                // Build SSE URL
                let urlString = "\(Endpoints.apiBase)/ai/proposals/generate/stream?missionId=\(missionId)"
                print("🔵 [STREAMING] SSE URL: \(urlString)")
                
                guard let url = URL(string: urlString) else {
                    print("❌ [STREAMING] Invalid URL: \(urlString)")
                    continuation.finish()
                    return
                }
                
                print("✅ [STREAMING] URL created successfully")
                
                // Create SSE client
                let sseClient = SSEClient()
                print("🔵 [STREAMING] SSE client created, connecting...")
                
                // Connect and process events
                var eventCount = 0
                for await event in sseClient.connect(url: url, token: token) {
                    eventCount += 1
                    print("📨 [STREAMING] Event #\(eventCount) received: \(event.data.prefix(100))...")
                    
                    // Parse the JSON data
                    if let jsonData = event.data.data(using: .utf8) {
                        do {
                            let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
                            
                            // Check for error
                            if let error = json?["error"] as? Bool, error == true {
                                let message = json?["message"] as? String ?? "Unknown error"
                                print("❌ [STREAMING] SSE Error: \(message)")
                                continuation.finish()
                                break
                            }
                            
                            // Check for done marker
                            if let done = json?["done"] as? Bool, done == true {
                                print("✅ [STREAMING] Stream complete (done marker received)")
                                continuation.finish()
                                break
                            }
                            
                            // Yield chunk
                            if let chunk = json?["chunk"] as? String {
                                print("📝 [STREAMING] Yielding chunk: \(chunk.prefix(50))...")
                                continuation.yield(chunk)
                            } else {
                                print("⚠️ [STREAMING] Event has no chunk field: \(json ?? [:])")
                            }
                        } catch {
                            print("❌ [STREAMING] Failed to parse SSE JSON: \(error)")
                            print("   Raw data: \(event.data)")
                        }
                    } else {
                        print("⚠️ [STREAMING] Could not convert event data to UTF8")
                    }
                }
                
                print("🔵 [STREAMING] SSE loop ended, total events: \(eventCount)")
                continuation.finish()
            }
        }
    }
    
    // MARK: - AI-Powered Proposal Ranking
    
    /// Get proposals for a specific mission with optional AI sorting
    /// - Parameters:
    ///   - missionId: ID of the mission
    ///   - aiSort: Whether to sort by AI compatibility score
    /// - Returns: Mission with its proposals
    func getProposalsForMission(missionId: String, aiSort: Bool = false) async throws -> MissionProposalsResponse {
        var url = Endpoints.apiBase + "/recruiter/proposals/mission/\(missionId)"
        if aiSort {
            url += "?sort=ai"
        }
        return try await ApiClient.shared.get(
            url: url,
            requiresAuth: true
        )
    }
    
    /// Search proposals by mission title
    /// - Parameter title: Search query for mission title
    /// - Returns: Array of missions with their proposals
    func searchProposalsByMissionTitle(_ title: String) async throws -> [MissionProposalsSearchResult] {
        let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? title
        let url = Endpoints.apiBase + "/recruiter/proposals?title=\(encodedTitle)"
        return try await ApiClient.shared.get(
            url: url,
            requiresAuth: true
        )
    }
}

struct GenerateProposalRequest: Codable {
    let missionId: String
}

struct GenerateProposalResponse: Codable {
    let proposalContent: String
}

struct UnreadProposalsCountResponse: Codable {
    let count: Int
}

// MARK: - AI Proposal Ranking Models

struct MissionProposalsResponse: Codable {
    let mission: MissionModel
    let proposals: [ProposalModel]
}

struct MissionProposalsSearchResult: Codable {
    let mission: MissionModel
    let proposalCount: Int
    let proposals: [ProposalModel]
}
