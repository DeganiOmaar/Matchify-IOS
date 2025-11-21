import Foundation
import UIKit
import AVFoundation

final class PortfolioService {
    static let shared = PortfolioService()
    private init() {}
    
    // MARK: - Get All Projects
    func getAllProjects() async throws -> ProjectsResponse {
        guard let token = AuthManager.shared.token else {
            throw NSError(domain: "", code: 401,
                          userInfo: [NSLocalizedDescriptionKey: "Missing token"])
        }
        
        guard let url = URL(string: Endpoints.portfolio) else {
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
            print("❌ Portfolio GET Error: \(http.statusCode) - \(serverMessage)")
            throw NSError(domain: "", code: http.statusCode,
                          userInfo: [NSLocalizedDescriptionKey: serverMessage])
        }
        
        // Debug: print raw response
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📦 Portfolio Response: \(jsonString.prefix(500))")
        }
        
        do {
            let decoded = try JSONDecoder().decode(ProjectsResponse.self, from: data)
            print("✅ Portfolio decoded successfully: \(decoded.projects.count) projects")
            return decoded
        } catch {
            print("❌ Portfolio decode error: \(error)")
            print("   Error details: \(error.localizedDescription)")
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("   Missing key: \(key.stringValue) in \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    print("   Type mismatch: expected \(type) in \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    print("   Value not found: \(type) in \(context.debugDescription)")
                case .dataCorrupted(let context):
                    print("   Data corrupted: \(context.debugDescription)")
                @unknown default:
                    print("   Unknown decoding error")
                }
            }
            throw error
        }
    }
    
    // MARK: - Get Single Project
    func getProject(id: String) async throws -> ProjectResponse {
        guard let token = AuthManager.shared.token else {
            throw NSError(domain: "", code: 401,
                          userInfo: [NSLocalizedDescriptionKey: "Missing token"])
        }
        
        guard let url = URL(string: Endpoints.portfolioProject(id: id)) else {
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
        
        return try JSONDecoder().decode(ProjectResponse.self, from: data)
    }
    
    // MARK: - Create Project
    func createProject(
        title: String,
        role: String?,
        skills: [String]?,
        description: String?,
        projectLink: String?,
        mediaItems: [ProjectMediaItem],
        existingMediaItems: [MediaItemModel] = []
    ) async throws -> ProjectResponse {
        guard let token = AuthManager.shared.token else {
            throw NSError(domain: "", code: 401,
                          userInfo: [NSLocalizedDescriptionKey: "Missing token"])
        }
        
        guard let url = URL(string: Endpoints.portfolio) else {
            throw NSError(domain: "", code: 500,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try makeMultipartBody(
            boundary: boundary,
            title: title,
            role: role,
            skills: skills,
            description: description,
            projectLink: projectLink,
            mediaItems: mediaItems,
            existingMediaItems: existingMediaItems
        )
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let http = response as? HTTPURLResponse,
           !(200...299).contains(http.statusCode) {
            let serverMessage = String(data: data, encoding: .utf8) ?? "Unknown server error"
            throw NSError(domain: "", code: http.statusCode,
                          userInfo: [NSLocalizedDescriptionKey: serverMessage])
        }
        
        return try JSONDecoder().decode(ProjectResponse.self, from: data)
    }
    
    // MARK: - Update Project
    func updateProject(
        id: String,
        title: String?,
        role: String?,
        skills: [String]?,
        description: String?,
        projectLink: String?,
        mediaItems: [ProjectMediaItem],
        existingMediaItems: [MediaItemModel] = []
    ) async throws -> ProjectResponse {
        guard let token = AuthManager.shared.token else {
            throw NSError(domain: "", code: 401,
                          userInfo: [NSLocalizedDescriptionKey: "Missing token"])
        }
        
        guard let url = URL(string: Endpoints.portfolioProject(id: id)) else {
            throw NSError(domain: "", code: 500,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try makeMultipartBody(
            boundary: boundary,
            title: title,
            role: role,
            skills: skills,
            description: description,
            projectLink: projectLink,
            mediaItems: mediaItems,
            existingMediaItems: existingMediaItems
        )
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let http = response as? HTTPURLResponse,
           !(200...299).contains(http.statusCode) {
            let serverMessage = String(data: data, encoding: .utf8) ?? "Unknown server error"
            throw NSError(domain: "", code: http.statusCode,
                          userInfo: [NSLocalizedDescriptionKey: serverMessage])
        }
        
        return try JSONDecoder().decode(ProjectResponse.self, from: data)
    }
    
    // MARK: - Delete Project
    func deleteProject(id: String) async throws {
        guard let token = AuthManager.shared.token else {
            throw NSError(domain: "", code: 401,
                          userInfo: [NSLocalizedDescriptionKey: "Missing token"])
        }
        
        guard let url = URL(string: Endpoints.portfolioProject(id: id)) else {
            throw NSError(domain: "", code: 500,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        if let http = response as? HTTPURLResponse,
           !(200...299).contains(http.statusCode) {
            throw NSError(domain: "", code: http.statusCode,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to delete project"])
        }
    }
    
    // MARK: - Multipart Body Builder
    private func makeMultipartBody(
        boundary: String,
        title: String?,
        role: String?,
        skills: [String]?,
        description: String?,
        projectLink: String?,
        mediaItems: [ProjectMediaItem],
        existingMediaItems: [MediaItemModel]
    ) throws -> Data {
        var body = Data()
        let line = "\r\n"
        
        func addField(_ name: String, _ value: String?) {
            guard let value = value, !value.isEmpty else { return }
            body.append("--\(boundary)\(line)")
            body.append("Content-Disposition: form-data; name=\"\(name)\"\(line)\(line)")
            body.append("\(value)\(line)")
        }
        
        if let title = title {
            addField("title", title)
        }
        
        addField("role", role)
        addField("description", description)
        addField("projectLink", projectLink)
        
        // Add skills as JSON array string
        if let skills = skills, !skills.isEmpty {
            if let skillsJSON = try? JSONEncoder().encode(skills),
               let skillsString = String(data: skillsJSON, encoding: .utf8) {
                addField("skills", skillsString)
            }
        }
        
        // Add uploaded media files
        for mediaItem in mediaItems {
            guard let fileData = mediaItem.fileData else { continue }
            
            body.append("--\(boundary)\(line)")
            body.append("Content-Disposition: form-data; name=\"media\"; filename=\"\(mediaItem.filename)\"\(line)")
            body.append("Content-Type: \(mediaItem.mimeType)\(line)\(line)")
            body.append(fileData)
            body.append(line)
        }
        
        // Add existing media items (for external links or to preserve existing media)
        // Backend expects "media" not "mediaItems"
        if !existingMediaItems.isEmpty {
            let mediaItemsArray = existingMediaItems.map { item in
                [
                    "type": item.type,
                    "url": item.url ?? "",
                    "title": item.title ?? "",
                    "externalLink": item.externalLink ?? ""
                ]
            }
            
            if let mediaItemsJSON = try? JSONSerialization.data(withJSONObject: mediaItemsArray),
               let mediaItemsString = String(data: mediaItemsJSON, encoding: .utf8) {
                addField("media", mediaItemsString)
            }
        }
        
        body.append("--\(boundary)--\(line)")
        return body
    }
}

// MARK: - Data Extension
private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) { append(data) }
    }
}

