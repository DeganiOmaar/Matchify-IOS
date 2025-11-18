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
            throw NSError(domain: "", code: http.statusCode,
                          userInfo: [NSLocalizedDescriptionKey: serverMessage])
        }
        
        return try JSONDecoder().decode(ProjectsResponse.self, from: data)
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
        media: MediaItem?
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
            media: media
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
        media: MediaItem?
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
            media: media
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
        media: MediaItem?
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
        
        // Add skills as JSON array string
        if let skills = skills, !skills.isEmpty {
            if let skillsJSON = try? JSONEncoder().encode(skills),
               let skillsString = String(data: skillsJSON, encoding: .utf8) {
                addField("skills", skillsString)
            }
        }
        
        // Add media file
        if let media = media {
            let fileData: Data
            let filename: String
            let mimeType: String
            
            switch media {
            case .image(let image):
                guard let jpegData = image.jpegData(compressionQuality: 0.85) else {
                    throw NSError(domain: "", code: 400,
                                  userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
                }
                fileData = jpegData
                filename = "portfolio-image-\(UUID().uuidString).jpg"
                mimeType = "image/jpeg"
                
            case .video(let url):
                fileData = try Data(contentsOf: url)
                let ext = url.pathExtension.lowercased()
                filename = "portfolio-video-\(UUID().uuidString).\(ext)"
                mimeType = ext == "mp4" ? "video/mp4" : "video/quicktime"
            }
            
            body.append("--\(boundary)\(line)")
            body.append("Content-Disposition: form-data; name=\"media\"; filename=\"\(filename)\"\(line)")
            body.append("Content-Type: \(mimeType)\(line)\(line)")
            body.append(fileData)
            body.append(line)
        }
        
        body.append("--\(boundary)--\(line)")
        return body
    }
}

// MARK: - Media Item Enum
enum MediaItem {
    case image(UIImage)
    case video(URL)
}

// MARK: - Data Extension
private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) { append(data) }
    }
}

