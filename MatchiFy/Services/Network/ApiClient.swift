import Foundation

final class ApiClient {
    static let shared = ApiClient()
    private init() {}

    func post<T: Codable, R: Codable>(
        url: String,
        body: T
    ) async throws -> R {
        
        guard let requestUrl = URL(string: url) else {
            throw ApiError.unknown
        }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        
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
