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
        
        // Decode success - only decode if we have data
        guard !data.isEmpty else {
            // Empty response is valid for some endpoints
            // Try to decode anyway, but handle gracefully
            do {
                return try JSONDecoder().decode(R.self, from: data)
            } catch {
                // If decoding fails on empty data, it might be expected
                throw ApiError.decoding
            }
        }
        
        do {
            return try JSONDecoder().decode(R.self, from: data)
        } catch let decodingError as DecodingError {
            // Log decoding error for debugging
            print("❌ Decoding error: \(decodingError)")
            if let dataString = String(data: data, encoding: .utf8) {
                print("📄 Response data: \(dataString.prefix(500))")
            }
            throw ApiError.decoding
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
        
        // Decode success - only decode if we have data
        guard !data.isEmpty else {
            // Empty response is valid for some endpoints
            // Try to decode anyway, but handle gracefully
            do {
                return try JSONDecoder().decode(R.self, from: data)
            } catch {
                // If decoding fails on empty data, it might be expected
                throw ApiError.decoding
            }
        }
        
        do {
            return try JSONDecoder().decode(R.self, from: data)
        } catch let decodingError as DecodingError {
            // Log decoding error for debugging
            print("❌ Decoding error: \(decodingError)")
            if let dataString = String(data: data, encoding: .utf8) {
                print("📄 Response data: \(dataString.prefix(500))")
            }
            throw ApiError.decoding
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
        
        // Decode success - only decode if we have data
        guard !data.isEmpty else {
            // Empty response is valid for some endpoints
            // Try to decode anyway, but handle gracefully
            do {
                return try JSONDecoder().decode(R.self, from: data)
            } catch {
                // If decoding fails on empty data, it might be expected
                throw ApiError.decoding
            }
        }
        
        do {
            return try JSONDecoder().decode(R.self, from: data)
        } catch let decodingError as DecodingError {
            // Log decoding error for debugging
            print("❌ Decoding error: \(decodingError)")
            if let dataString = String(data: data, encoding: .utf8) {
                print("📄 Response data: \(dataString.prefix(500))")
            }
            throw ApiError.decoding
        } catch {
            throw ApiError.decoding
        }
    }
    
    // MARK: - PATCH Request with Auth
    func patch<T: Codable, R: Codable>(
        url: String,
        body: T,
        requiresAuth: Bool = true
    ) async throws -> R {
        guard let requestUrl = URL(string: url) else {
            throw ApiError.unknown
        }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "PATCH"
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
        
        // Decode success - only decode if we have data
        guard !data.isEmpty else {
            // Empty response is valid for some endpoints
            // Try to decode anyway, but handle gracefully
            do {
                return try JSONDecoder().decode(R.self, from: data)
            } catch {
                // If decoding fails on empty data, it might be expected
                throw ApiError.decoding
            }
        }
        
        do {
            return try JSONDecoder().decode(R.self, from: data)
        } catch let decodingError as DecodingError {
            // Log decoding error for debugging
            print("❌ Decoding error: \(decodingError)")
            if let dataString = String(data: data, encoding: .utf8) {
                print("📄 Response data: \(dataString.prefix(500))")
            }
            throw ApiError.decoding
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
        
        // Decode success - only decode if we have data
        guard !data.isEmpty else {
            // Empty response is valid for some endpoints
            // Try to decode anyway, but handle gracefully
            do {
                return try JSONDecoder().decode(R.self, from: data)
            } catch {
                // If decoding fails on empty data, it might be expected
                throw ApiError.decoding
            }
        }
        
        do {
            return try JSONDecoder().decode(R.self, from: data)
        } catch let decodingError as DecodingError {
            // Log decoding error for debugging
            print("❌ Decoding error: \(decodingError)")
            if let dataString = String(data: data, encoding: .utf8) {
                print("📄 Response data: \(dataString.prefix(500))")
            }
            throw ApiError.decoding
        } catch {
            throw ApiError.decoding
        }
    }
    
    private func decodeError<R>(_ data: String) throws -> R {
        // Try to parse JSON error response
        if let jsonData = data.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
            
            // Check for structured validation errors with missingFields
            if let missingFields = json["missingFields"] as? [String],
               let fieldErrors = json["fieldErrors"] as? [String: String],
               !missingFields.isEmpty {
                // Build a detailed error message
                let fieldNames = missingFields.map { field in
                    // Capitalize first letter and add space before capital letters
                    field.prefix(1).uppercased() + field.dropFirst()
                        .replacingOccurrences(of: "([A-Z])", with: " $1", options: .regularExpression)
                }
                let errorMessage = "Missing required fields: \(fieldNames.joined(separator: ", "))"
                throw ApiError.server(errorMessage)
            }
            
            // Try common error message fields
            if let message = json["message"] as? String {
                throw ApiError.server(message)
            }
            if let error = json["error"] as? String {
                throw ApiError.server(error)
            }
            if let msg = json["msg"] as? String {
                throw ApiError.server(msg)
            }
        }
        // Fallback to raw message
        throw ApiError.server(data)
    }
}
