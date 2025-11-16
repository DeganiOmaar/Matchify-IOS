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
            return "Erreur lors du traitement des données. Veuillez réessayer."
        }
        
        // Handle unknown errors
        if case ApiError.unknown = error {
            return "Une erreur s'est produite. Veuillez réessayer."
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
            return "Email ou mot de passe incorrect."
        }
        
        if lowerMessage.contains("password") && (lowerMessage.contains("incorrect") || lowerMessage.contains("wrong")) {
            return "Mot de passe incorrect."
        }
        
        if lowerMessage.contains("email") && (lowerMessage.contains("not found") || lowerMessage.contains("doesn't exist")) {
            return "Aucun compte trouvé avec cet email."
        }
        
        // Validation errors
        if lowerMessage.contains("required") || lowerMessage.contains("missing") {
            return "Veuillez remplir tous les champs requis."
        }
        
        if lowerMessage.contains("email") && lowerMessage.contains("invalid") {
            return "Format d'email invalide."
        }
        
        if lowerMessage.contains("password") && lowerMessage.contains("weak") {
            return "Le mot de passe est trop faible. Utilisez au moins 6 caractères."
        }
        
        if lowerMessage.contains("already exists") || lowerMessage.contains("already registered") {
            return getConflictMessage(context: context)
        }
        
        // Network errors
        if lowerMessage.contains("network") || lowerMessage.contains("connection") {
            return "Problème de connexion. Vérifiez votre connexion internet."
        }
        
        if lowerMessage.contains("timeout") {
            return "La connexion a expiré. Veuillez réessayer."
        }
        
        // If message seems user-friendly already, return it
        if message.count < 100 && !message.contains("http") && !message.contains("exception") {
            return message
        }
        
        // Default fallback
        return "Une erreur s'est produite. Veuillez réessayer."
    }
    
    /// Handles URL errors (network issues)
    private static func handleURLError(_ error: URLError) -> String {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return "Problème de connexion. Vérifiez votre connexion internet."
        case .timedOut:
            return "La connexion a expiré. Veuillez réessayer."
        case .cannotFindHost, .cannotConnectToHost:
            return "Impossible de se connecter au serveur. Veuillez réessayer plus tard."
        default:
            return "Problème de connexion. Veuillez réessayer."
        }
    }
    
    private static func getUnauthorizedMessage(context: ErrorContext) -> String {
        switch context {
        case .login:
            return "Email ou mot de passe incorrect."
        case .signup:
            return "Erreur d'authentification. Veuillez réessayer."
        case .profileUpdate:
            return "Votre session a expiré. Veuillez vous reconnecter."
        case .missionCreate, .missionUpdate, .missionDelete:
            return "Vous devez être connecté pour effectuer cette action."
        case .passwordReset:
            return "Le code de vérification est incorrect ou a expiré."
        default:
            return "Vous n'êtes pas autorisé à effectuer cette action."
        }
    }
    
    private static func getConflictMessage(context: ErrorContext) -> String {
        switch context {
        case .signup:
            return "Un compte existe déjà avec cet email."
        case .profileUpdate:
            return "Cet email est déjà utilisé par un autre compte."
        default:
            return "Cette ressource existe déjà."
        }
    }
}

