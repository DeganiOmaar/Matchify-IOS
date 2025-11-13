import Foundation

enum ApiError: Error, LocalizedError {
    case server(String)
    case decoding
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .server(let message): return message
        case .decoding: return "Failed to decode server response"
        case .unknown: return "Something went wrong"
        }
    }
}
