import Foundation
import Combine

final class AIProfileInsightsViewModel: ObservableObject {
    @Published var analysis: ProfileAnalysisResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let service = AIProfileService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // Cache the analysis result
    private var cachedAnalysis: ProfileAnalysisResponse?
    
    init() {
        // Try to load cached result on init
        loadCachedAnalysis()
    }
    
    func analyzeProfile(onError: @escaping (String) -> Void) {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task { @MainActor in
            do {
                let result = try await service.analyzeProfile()
                self.analysis = result
                self.cachedAnalysis = result
                self.isLoading = false
            } catch {
                self.isLoading = false
                
                // Handle specific error cases
                var message: String
                if let apiError = error as? ApiError {
                    switch apiError {
                    case .server(let msg):
                        if msg.lowercased().contains("rate limit") {
                            message = "Limite d'analyses atteinte. Réessayez demain."
                        } else if msg.lowercased().contains("unavailable") {
                            message = "Le service d'analyse est temporairement indisponible. Réessayez plus tard."
                        } else {
                            message = msg
                        }
                    case .decoding:
                        message = "Erreur lors de l'analyse du profil. Réessayez plus tard."
                    case .unknown:
                        message = "Erreur inconnue. Vérifiez votre connexion et réessayez."
                    }
                } else {
                    message = error.localizedDescription
                }
                
                self.errorMessage = message
                onError(message)
            }
        }
    }
    
    func loadLatestAnalysis() {
        guard !isLoading else { return }
        
        // If we have cached analysis, use it first
        if let cached = cachedAnalysis {
            analysis = cached
        }
        
        isLoading = true
        errorMessage = nil
        
        Task { @MainActor in
            do {
                let result = try await service.getLatestAnalysis()
                self.analysis = result
                self.cachedAnalysis = result
                self.isLoading = false
            } catch {
                self.isLoading = false
                // Don't show error for "not found" - just means no analysis yet
                if let apiError = error as? ApiError,
                   case .server(let message) = apiError,
                   message.lowercased().contains("not found") {
                    // No analysis found - this is OK, user can trigger one
                    return
                }
                
                // Only show error for real errors
                if let apiError = error as? ApiError {
                    switch apiError {
                    case .server(let message):
                        self.errorMessage = message
                    default:
                        break
                    }
                }
            }
        }
    }
    
    private func loadCachedAnalysis() {
        // Try to load latest analysis in background (non-blocking)
        Task { @MainActor in
            await loadLatestAnalysisSilently()
        }
    }
    
    private func loadLatestAnalysisSilently() async {
        do {
            let result = try await service.getLatestAnalysis()
            await MainActor.run {
                self.analysis = result
                self.cachedAnalysis = result
            }
        } catch {
            // Silently fail - user can trigger analysis manually
            // Check if it's a "not found" error - that's expected if no analysis exists yet
            if let apiError = error as? ApiError,
               case .server(let message) = apiError,
               message.lowercased().contains("not found") {
                // This is expected - no analysis exists yet
                return
            }
            // For other errors, silently fail
        }
    }
}

