import Foundation

final class ApiClient {
    static let shared = ApiClient()
    private init() {}
    
    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        // Handle both with and without fractional seconds
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            if let date = formatter.date(from: dateString) {
                return date
            }
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            if let date = formatter.date(from: dateString) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
        }
        return decoder
    }

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
                return try self.decoder.decode(R.self, from: data)
            } catch {
                // If decoding fails on empty data, it might be expected
                throw ApiError.decoding
            }
        }
        
        do {
            return try self.decoder.decode(R.self, from: data)
        } catch let decodingError as DecodingError {
            // Log decoding error for debugging
            print("❌ Decoding error: \(decodingError)")
            let dataString = String(data: data, encoding: .utf8) ?? "binary"
            throw ApiError.server("Decoding failed: \(decodingError). Data: \(dataString.prefix(100))")
        } catch {
            throw ApiError.server("Decoding failed: \(error.localizedDescription)")
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
                return try self.decoder.decode(R.self, from: data)
            } catch {
                // If decoding fails on empty data, it might be expected
                throw ApiError.decoding
            }
        }
        
        do {
            return try self.decoder.decode(R.self, from: data)
        } catch let decodingError as DecodingError {
            // Log decoding error for debugging
            print("❌ Decoding error: \(decodingError)")
            let dataString = String(data: data, encoding: .utf8) ?? "binary"
            throw ApiError.server("Decoding failed: \(decodingError). Data: \(dataString.prefix(100))")
        } catch {
            throw ApiError.server("Decoding failed: \(error.localizedDescription)")
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
                return try self.decoder.decode(R.self, from: data)
            } catch {
                // If decoding fails on empty data, it might be expected
                throw ApiError.decoding
            }
        }
        
        do {
            return try self.decoder.decode(R.self, from: data)
        } catch let decodingError as DecodingError {
            // Log decoding error for debugging
            print("❌ Decoding error: \(decodingError)")
            let dataString = String(data: data, encoding: .utf8) ?? "binary"
            throw ApiError.server("Decoding failed: \(decodingError). Data: \(dataString.prefix(100))")
        } catch {
            throw ApiError.server("Decoding failed: \(error.localizedDescription)")
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
                return try self.decoder.decode(R.self, from: data)
            } catch {
                // If decoding fails on empty data, it might be expected
                throw ApiError.decoding
            }
        }
        
        do {
            return try self.decoder.decode(R.self, from: data)
        } catch let decodingError as DecodingError {
            // Log decoding error for debugging
            print("❌ Decoding error: \(decodingError)")
            let dataString = String(data: data, encoding: .utf8) ?? "binary"
            throw ApiError.server("Decoding failed: \(decodingError). Data: \(dataString.prefix(100))")
        } catch {
            throw ApiError.server("Decoding failed: \(error.localizedDescription)")
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
                return try self.decoder.decode(R.self, from: data)
            } catch {
                // If decoding fails on empty data, it might be expected
                throw ApiError.decoding
            }
        }
        
        do {
            return try self.decoder.decode(R.self, from: data)
        } catch let decodingError as DecodingError {
            // Log decoding error for debugging
            print("❌ Decoding error: \(decodingError)")
            let dataString = String(data: data, encoding: .utf8) ?? "binary"
            throw ApiError.server("Decoding failed: \(decodingError). Data: \(dataString.prefix(100))")
        } catch {
            throw ApiError.server("Decoding failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Upload Request with Auth
    func upload<R: Codable>(
        url: String,
        data: Data,
        boundary: String,
        headers: [String: String],
        requiresAuth: Bool = true
    ) async throws -> R {
        guard let requestUrl = URL(string: url) else {
            throw ApiError.unknown
        }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        // Add headers
        for (key, value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        // Add Authorization header if required
        if requiresAuth {
            guard let token = AuthManager.shared.token else {
                throw ApiError.server("Missing authentication token")
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = data
        
        let (responseData, response) = try await URLSession.shared.data(for: request)
        
        // Server status handling
        if let httpResponse = response as? HTTPURLResponse {
            if !(200...299).contains(httpResponse.statusCode) {
                let serverMessage = String(decoding: responseData, as: UTF8.self)
                return try decodeError(serverMessage)
            }
        }
        
        // Decode success
        do {
            return try self.decoder.decode(R.self, from: responseData)
        } catch let decodingError as DecodingError {
            print("❌ Decoding error: \(decodingError)")
            if let dataString = String(data: responseData, encoding: .utf8) {
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
