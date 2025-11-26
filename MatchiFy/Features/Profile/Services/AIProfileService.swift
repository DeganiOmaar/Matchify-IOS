import Foundation

final class AIProfileService {
    static let shared = AIProfileService()
    private init() {}
    
    // MARK: - Analyze Profile
    func analyzeProfile() async throws -> ProfileAnalysisResponse {
        // POST request - backend uses authenticated user, no body needed
        // We need to make a custom POST request with empty body
        guard let requestUrl = URL(string: Endpoints.aiProfileAnalysis) else {
            throw ApiError.unknown
        }
        
        guard let token = AuthManager.shared.token else {
            throw ApiError.server("Missing authentication token")
        }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = "{}".data(using: .utf8) // Empty JSON body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            if !(200...299).contains(httpResponse.statusCode) {
                let serverMessage = String(decoding: data, as: UTF8.self)
                throw ApiError.server(serverMessage)
            }
        }
        
        do {
            return try JSONDecoder().decode(ProfileAnalysisResponse.self, from: data)
        } catch {
            throw ApiError.decoding
        }
    }
    
    // MARK: - Get Latest Analysis
    func getLatestAnalysis() async throws -> ProfileAnalysisResponse {
        return try await ApiClient.shared.get(
            url: Endpoints.aiProfileAnalysisLatest,
            requiresAuth: true
        )
    }
}

