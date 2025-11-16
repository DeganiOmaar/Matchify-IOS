import Foundation

final class ApiClient {
    static let shared = ApiClient()
    private init() {}

    // MARK: - POST Request (backward compatible for auth endpoints)
    func post<T: Codable, R: Codable>(
        url: String,
        body: T
    ) async throws -> R {
        return try await post(url: url, body: body, requiresAuth: false)
    }
    
    // MARK: - POST Request with Auth
    func post<T: Codable, R: Codable>(
        url: String,
        body: T,
        requiresAuth: Bool = true
    ) async throws -> R {
        guard let requestUrl = URL(string: url) else {
            throw ApiError.unknown
        }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        
        // Add Authorization header if required
        if requiresAuth {
            guard let token = AuthManager.shared.token else {
                throw ApiError.server("Missing authentication token")
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Server status handling
        if let httpResponse = response as? HTTPURLResponse {
            if !(200...299).contains(httpResponse.statusCode) {
                let serverMessage = String(decoding: data, as: UTF8.self)
                return try decodeError(serverMessage)
            }
        }
        
        // Decode success
        do {
            return try JSONDecoder().decode(R.self, from: data)
        } catch {
            throw ApiError.decoding
        }
    }
    
    // MARK: - GET Request with Auth
    func get<R: Codable>(
        url: String,
        requiresAuth: Bool = true
    ) async throws -> R {
        guard let requestUrl = URL(string: url) else {
            throw ApiError.unknown
        }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add Authorization header if required
        if requiresAuth {
            guard let token = AuthManager.shared.token else {
                throw ApiError.server("Missing authentication token")
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Server status handling
        if let httpResponse = response as? HTTPURLResponse {
            if !(200...299).contains(httpResponse.statusCode) {
                let serverMessage = String(decoding: data, as: UTF8.self)
                return try decodeError(serverMessage)
            }
        }
        
        // Decode success
        do {
            return try JSONDecoder().decode(R.self, from: data)
        } catch {
            throw ApiError.decoding
        }
    }
    
    // MARK: - PUT Request with Auth
    func put<T: Codable, R: Codable>(
        url: String,
        body: T,
        requiresAuth: Bool = true
    ) async throws -> R {
        guard let requestUrl = URL(string: url) else {
            throw ApiError.unknown
        }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        
        // Add Authorization header if required
        if requiresAuth {
            guard let token = AuthManager.shared.token else {
                throw ApiError.server("Missing authentication token")
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Server status handling
        if let httpResponse = response as? HTTPURLResponse {
            if !(200...299).contains(httpResponse.statusCode) {
                let serverMessage = String(decoding: data, as: UTF8.self)
                return try decodeError(serverMessage)
            }
        }
        
        // Decode success
        do {
            return try JSONDecoder().decode(R.self, from: data)
        } catch {
            throw ApiError.decoding
        }
    }
    
    // MARK: - DELETE Request with Auth
    func delete<R: Codable>(
        url: String,
        requiresAuth: Bool = true
    ) async throws -> R {
        guard let requestUrl = URL(string: url) else {
            throw ApiError.unknown
        }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add Authorization header if required
        if requiresAuth {
            guard let token = AuthManager.shared.token else {
                throw ApiError.server("Missing authentication token")
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Server status handling
        if let httpResponse = response as? HTTPURLResponse {
            if !(200...299).contains(httpResponse.statusCode) {
                let serverMessage = String(decoding: data, as: UTF8.self)
                return try decodeError(serverMessage)
            }
        }
        
        // Decode success
        do {
            return try JSONDecoder().decode(R.self, from: data)
        } catch {
            throw ApiError.decoding
        }
    }
    
    private func decodeError<R>(_ data: String) throws -> R {
        throw ApiError.server(data)
    }
}
