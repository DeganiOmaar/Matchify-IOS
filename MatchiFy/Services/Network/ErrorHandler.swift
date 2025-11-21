import Foundation

/// Centralized error handler that converts technical backend errors
/// into user-friendly messages
enum ErrorHandler {
    
    enum ErrorContext {
        case general
        case login
        case signup
        case profileUpdate
        case missionCreate
        case missionUpdate
        case missionDelete
        case passwordReset
        case forgotPassword
        case verifyCode
        case portfolioCreate
        case portfolioUpdate
        case portfolioDelete
        case network
    }
    
    /// Extracts user-friendly error message from error
    static func getErrorMessage(from error: Error, context: ErrorContext = .general) -> String {
        // Handle ApiError
        if case ApiError.server(let message) = error {
            return mapTechnicalMessage(message, context: context)
        }
        
        // Handle URLError (network errors)
        if let urlError = error as? URLError {
            return handleURLError(urlError)
        }
        
        // Handle decoding errors
        if case ApiError.decoding = error {
            return "Error processing data. Please try again."
        }
        
        // Handle unknown errors
        if case ApiError.unknown = error {
            return "An error occurred. Please try again."
        }
        
        // Try to extract message from error
        let message = error.localizedDescription
        return mapTechnicalMessage(message, context: context)
    }
    
    /// Maps technical error messages to user-friendly ones
    private static func mapTechnicalMessage(_ message: String, context: ErrorContext) -> String {
        let lowerMessage = message.lowercased()
        
        // Authentication errors
        if lowerMessage.contains("unauthorized") || lowerMessage.contains("invalid credentials") {
            return getUnauthorizedMessage(context: context)
        }
        
        if lowerMessage.contains("email") && lowerMessage.contains("password") {
            return "Incorrect email or password."
        }
        
        if lowerMessage.contains("password") && (lowerMessage.contains("incorrect") || lowerMessage.contains("wrong")) {
            return "Incorrect password."
        }
        
        if lowerMessage.contains("email") && (lowerMessage.contains("not found") || lowerMessage.contains("doesn't exist")) {
            return "No account found with this email."
        }
        
        // Validation errors - check for structured error messages first
        // IMPORTANT: Only treat as validation error if it's explicitly an error response
        // Don't interpret success messages or other content as validation errors
        
        if lowerMessage.contains("missing required fields:") {
            // This is a structured error from ApiClient, return it as-is
            return message
        }
        
        // Only treat as validation error if it's clearly an error message
        // Check for error indicators first
        let isErrorContext = lowerMessage.contains("error") || 
                            lowerMessage.contains("failed") || 
                            lowerMessage.contains("invalid") ||
                            lowerMessage.contains("exception") ||
                            lowerMessage.contains("bad request") ||
                            lowerMessage.contains("validation failed")
        
        if isErrorContext && (lowerMessage.contains("required") || lowerMessage.contains("missing")) {
            // Check if it's a contract validation error
            if lowerMessage.contains("contract validation failed") {
                return "Le contrat est incomplet. Veuillez vérifier tous les champs requis."
            }
            return "Veuillez remplir tous les champs requis."
        }
        
        // Don't treat standalone "required" or "missing" as errors if not in error context
        // This prevents false positives from success messages
        
        if lowerMessage.contains("email") && lowerMessage.contains("invalid") {
            return "Invalid email format."
        }
        
        if lowerMessage.contains("password") && lowerMessage.contains("weak") {
            return "Password is too weak. Use at least 6 characters."
        }
        
        if lowerMessage.contains("already exists") || lowerMessage.contains("already registered") {
            return getConflictMessage(context: context)
        }
        
        // Network errors
        if lowerMessage.contains("network") || lowerMessage.contains("connection") {
            return "Connection problem. Check your internet connection."
        }
        
        if lowerMessage.contains("timeout") {
            return "Connection timed out. Please try again."
        }
        
        // If message seems user-friendly already, return it
        if message.count < 100 && !message.contains("http") && !message.contains("exception") {
            return message
        }
        
        // Default fallback
        return "An error occurred. Please try again."
    }
    
    /// Handles URL errors (network issues)
    private static func handleURLError(_ error: URLError) -> String {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return "Connection problem. Check your internet connection."
        case .timedOut:
            return "Connection timed out. Please try again."
        case .cannotFindHost, .cannotConnectToHost:
            return "Unable to connect to server. Please try again later."
        default:
            return "Connection problem. Please try again."
        }
    }
    
    private static func getUnauthorizedMessage(context: ErrorContext) -> String {
        switch context {
        case .login:
            return "Incorrect email or password."
        case .signup:
            return "Authentication error. Please try again."
        case .profileUpdate:
            return "Your session has expired. Please log in again."
        case .missionCreate, .missionUpdate, .missionDelete:
            return "You must be logged in to perform this action."
        case .portfolioCreate, .portfolioUpdate, .portfolioDelete:
            return "You must be logged in to manage your portfolio."
        case .passwordReset:
            return "Verification code is incorrect or has expired."
        default:
            return "You are not authorized to perform this action."
        }
    }
    
    private static func getConflictMessage(context: ErrorContext) -> String {
        switch context {
        case .signup:
            return "An account already exists with this email."
        case .profileUpdate:
            return "This email is already used by another account."
        default:
            return "This resource already exists."
        }
    }
}

