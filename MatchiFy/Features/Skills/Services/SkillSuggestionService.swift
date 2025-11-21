import Foundation

final class SkillSuggestionService {
    static let shared = SkillSuggestionService()
    private init() {}
    
    // MARK: - Search Skills
    func searchSkills(query: String) async throws -> [SkillModel] {
        guard let token = AuthManager.shared.token else {
            throw NSError(domain: "", code: 401,
                          userInfo: [NSLocalizedDescriptionKey: "Missing token"])
        }
        
        // Build URL with query parameter
        var components = URLComponents(string: Endpoints.skillsSearch)
        components?.queryItems = [
            URLQueryItem(name: "query", value: query)
        ]
        
        guard let url = components?.url else {
            throw NSError(domain: "", code: 500,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let http = response as? HTTPURLResponse,
           !(200...299).contains(http.statusCode) {
            let serverMessage = String(data: data, encoding: .utf8) ?? "Unknown server error"
            throw NSError(domain: "", code: http.statusCode,
                          userInfo: [NSLocalizedDescriptionKey: serverMessage])
        }
        
        return try JSONDecoder().decode([SkillModel].self, from: data)
    }
    
    // MARK: - Get Skills by IDs
    func getSkillsByIds(_ ids: [String]) async throws -> [SkillModel] {
        guard !ids.isEmpty else {
            print("⚠️ [SkillSuggestionService] Aucun ID fourni")
            return []
        }
        
        guard let token = AuthManager.shared.token else {
            print("❌ [SkillSuggestionService] Token manquant")
            throw NSError(domain: "", code: 401,
                          userInfo: [NSLocalizedDescriptionKey: "Missing token"])
        }
        
        let urlString = Endpoints.skillsByIds(ids: ids)
        print("🌐 [SkillSuggestionService] URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("❌ [SkillSuggestionService] URL invalide: \(urlString)")
            throw NSError(domain: "", code: 500,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("📤 [SkillSuggestionService] Envoi de la requête...")
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let http = response as? HTTPURLResponse {
            print("📥 [SkillSuggestionService] Réponse reçue: status \(http.statusCode)")
            if !(200...299).contains(http.statusCode) {
                let serverMessage = String(data: data, encoding: .utf8) ?? "Unknown server error"
                print("❌ [SkillSuggestionService] Erreur serveur: \(serverMessage)")
                throw NSError(domain: "", code: http.statusCode,
                              userInfo: [NSLocalizedDescriptionKey: serverMessage])
            }
        }
        
        print("📦 [SkillSuggestionService] Données reçues: \(data.count) bytes")
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📄 [SkillSuggestionService] Réponse JSON: \(String(jsonString.prefix(500)))")
        }
        
        let skills = try JSONDecoder().decode([SkillModel].self, from: data)
        print("✅ [SkillSuggestionService] Skills décodées: \(skills.count) skills")
        return skills
    }
}

