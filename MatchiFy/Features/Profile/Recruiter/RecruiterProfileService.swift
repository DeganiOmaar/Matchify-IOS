import Foundation
import UIKit

final class RecruiterProfileService {
    static let shared = RecruiterProfileService()
    private init() {}

    func getRecruiterProfile() async throws -> UpdateRecruiterProfileResponse {
        guard let token = AuthManager.shared.token else {
            throw NSError(domain: "", code: 401,
                          userInfo: [NSLocalizedDescriptionKey: "Missing token"])
        }

        guard let url = URL(string: Endpoints.recruiterProfile) else {
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

        return try JSONDecoder().decode(UpdateRecruiterProfileResponse.self, from: data)
    }

    func updateRecruiterProfile(
        fullName: String?,
        email: String?,
        phone: String?,
        location: String?,
        profileImage: UIImage?,
        description: String?
    ) async throws -> UpdateRecruiterProfileResponse {

        guard let token = AuthManager.shared.token else {
            throw NSError(domain: "", code: 401,
                          userInfo: [NSLocalizedDescriptionKey: "Missing token"])
        }

        guard let url = URL(string: Endpoints.recruiterProfile) else {
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
            profileImage: profileImage,
            description: description
        )

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse,
           !(200...299).contains(http.statusCode) {

            let serverMessage = String(data: data, encoding: .utf8) ?? "Unknown server error"
            throw NSError(domain: "", code: http.statusCode,
                          userInfo: [NSLocalizedDescriptionKey: serverMessage])
        }

        return try JSONDecoder().decode(UpdateRecruiterProfileResponse.self, from: data)
    }

    private func makeMultipartBody(
        boundary: String,
        fullName: String?,
        email: String?,
        phone: String?,
        location: String?,
        profileImage: UIImage?,
        description: String?
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
