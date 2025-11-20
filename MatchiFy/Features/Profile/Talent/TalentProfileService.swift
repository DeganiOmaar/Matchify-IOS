import Foundation
import UIKit

final class TalentProfileService {
    static let shared = TalentProfileService()
    private init() {}

    func getTalentProfile() async throws -> UpdateTalentProfileResponse {
        guard let token = AuthManager.shared.token else {
            throw NSError(domain: "", code: 401,
                          userInfo: [NSLocalizedDescriptionKey: "Missing token"])
        }

        guard let url = URL(string: Endpoints.talentProfile) else {
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

        return try JSONDecoder().decode(UpdateTalentProfileResponse.self, from: data)
    }

    func updateTalentProfile(
        fullName: String?,
        email: String?,
        phone: String?,
        location: String?,
        talent: [String]?,
        skills: [String]?,
        description: String?,
        portfolioLink: String?,
        profileImage: UIImage?
    ) async throws -> UpdateTalentProfileResponse {

        guard let token = AuthManager.shared.token else {
            throw NSError(domain: "", code: 401,
                          userInfo: [NSLocalizedDescriptionKey: "Missing token"])
        }

        guard let url = URL(string: Endpoints.talentProfile) else {
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
            fullName: fullName,
            email: email,
            phone: phone,
            location: location,
            talent: talent,
            skills: skills,
            description: description,
            portfolioLink: portfolioLink,
            profileImage: profileImage
        )

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse,
           !(200...299).contains(http.statusCode) {
            
            // Try to extract error message from server response
            var serverMessage = "Unknown server error"
            if let dataString = String(data: data, encoding: .utf8) {
                print("❌ Erreur serveur (code \(http.statusCode)): \(dataString)")
                
                // Try to parse as JSON to extract message
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let message = json["message"] as? String {
                        serverMessage = message
                    } else if let error = json["error"] as? String {
                        serverMessage = error
                    } else if let msg = json["msg"] as? String {
                        serverMessage = msg
                    }
                } else {
                    // If not JSON, use the raw string (truncated if too long)
                    serverMessage = dataString.count > 200 ? String(dataString.prefix(200)) : dataString
                }
            }
            
            throw NSError(domain: "", code: http.statusCode,
                          userInfo: [NSLocalizedDescriptionKey: serverMessage])
        }

        return try JSONDecoder().decode(UpdateTalentProfileResponse.self, from: data)
    }

    private func makeMultipartBody(
        boundary: String,
        fullName: String?,
        email: String?,
        phone: String?,
        location: String?,
        talent: [String]?,
        skills: [String]?,
        description: String?,
        portfolioLink: String?,
        profileImage: UIImage?
    ) throws -> Data {

        var body = Data()
        let line = "\r\n"

        func addField(_ name: String, _ value: String?) {
            guard let value = value, !value.isEmpty else { return }

            body.append("--\(boundary)\(line)")
            body.append("Content-Disposition: form-data; name=\"\(name)\"\(line)\(line)")
            body.append("\(value)\(line)")
        }
            
        addField("fullName", fullName)
        addField("email", email)
        addField("phone", phone)
        addField("location", location)
        addField("description", description)
        addField("portfolioLink", portfolioLink)
        
        // Add talent as JSON array string
        if let talent = talent, !talent.isEmpty {
            if let talentJSON = try? JSONEncoder().encode(talent),
               let talentString = String(data: talentJSON, encoding: .utf8) {
                addField("talent", talentString)
            }
        }
        
        // Add skills as JSON array string
        if let skills = skills, !skills.isEmpty {
            // Ensure all skill names are valid strings
            let validSkills = skills.compactMap { skill in
                let trimmed = skill.trimmingCharacters(in: .whitespacesAndNewlines)
                return trimmed.isEmpty ? nil : trimmed
            }
            
            if !validSkills.isEmpty {
                if let skillsJSON = try? JSONEncoder().encode(validSkills),
                   let skillsString = String(data: skillsJSON, encoding: .utf8) {
                    addField("skills", skillsString)
                    print("📤 Envoi des skills: \(validSkills)")
                } else {
                    print("❌ Erreur lors de l'encodage JSON des skills")
                }
            }
        }

        if let image = profileImage,
           let data = image.jpegData(compressionQuality: 0.85) {

            body.append("--\(boundary)\(line)")
            body.append("Content-Disposition: form-data; name=\"profileImage\"; filename=\"avatar.jpg\"\(line)")
            body.append("Content-Type: image/jpeg\(line)\(line)")
            body.append(data)
            body.append(line)
        }

        body.append("--\(boundary)--\(line)")
        return body
    }
}

private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) { append(data) }
    }
}

