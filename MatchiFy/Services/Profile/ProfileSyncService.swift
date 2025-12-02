import Foundation
import Combine

/// Service responsable de la synchronisation automatique du profil talent
/// Déclenche l'analyse AI et le rafraîchissement de Best Match après chaque mise à jour de profil
final class ProfileSyncService: ObservableObject {
    static let shared = ProfileSyncService()
    private init() {}
    
    private let aiService = AIProfileService.shared
    private let missionService = MissionService.shared
    private var syncTask: Task<Void, Never>? = nil
    
    /// Notification publiée quand la synchronisation commence
    @Published var isSyncing: Bool = false
    
    /// Notification publiée pour les erreurs de synchronisation
    @Published var syncError: String? = nil
    
    /// Notification publiée quand la synchronisation est terminée avec succès
    @Published var syncCompleted: Bool = false
    
    /// Déclenche la synchronisation complète du profil
    /// 1. Rafraîchit l'analyse AI du profil
    /// 2. Rafraîchit la liste Best Match
    /// 3. Gère les erreurs avec retry automatique
    @MainActor
    func syncProfile() {
        // Annuler toute synchronisation en cours
        syncTask?.cancel()
        
        // Vérifier que l'utilisateur est un talent
        guard AuthManager.shared.role == "talent" else {
            print("⚠️ ProfileSyncService: Utilisateur n'est pas un talent, synchronisation ignorée")
            return
        }
        
        isSyncing = true
        syncError = nil
        syncCompleted = false
        
        syncTask = Task { @MainActor in
            await performSync()
        }
    }
    
    /// Effectue la synchronisation avec retry automatique
    @MainActor
    private func performSync() async {
        // Étape 1: Rafraîchir l'analyse AI du profil
        do {
            print("🔄 ProfileSyncService: Début de la synchronisation du profil...")
            
            // Appel de l'endpoint refresh qui bypass le rate limit
            let analysis = try await refreshProfileAnalysis()
            print("✅ ProfileSyncService: Analyse AI rafraîchie avec succès")
            
            // Notify that profile analysis was refreshed - this will trigger Best Match refresh
            NotificationCenter.default.post(
                name: NSNotification.Name("AIProfileAnalysisDidRefresh"),
                object: nil
            )
            
            // Petite pause pour s'assurer que le backend a bien sauvegardé l'analyse
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 secondes
            
            // Étape 2: Rafraîchir Best Match
            try await refreshBestMatch()
            print("✅ ProfileSyncService: Best Match rafraîchi avec succès")
            
            isSyncing = false
            syncCompleted = true
            print("✅ ProfileSyncService: Synchronisation complète terminée")
            
            // Réinitialiser syncCompleted après un court délai pour permettre aux observateurs de réagir
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 secondes
                syncCompleted = false
            }
            
        } catch let initialError {
            print("❌ ProfileSyncService: Erreur lors de la synchronisation: \(initialError.localizedDescription)")
            
            // Retry automatique après 3 secondes
            try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 secondes
            
            do {
                print("🔄 ProfileSyncService: Retry de la synchronisation...")
                let analysis = try await refreshProfileAnalysis()
                
                // Notify that profile analysis was refreshed - this will trigger Best Match refresh
                NotificationCenter.default.post(
                    name: NSNotification.Name("AIProfileAnalysisDidRefresh"),
                    object: nil
                )
                
                try? await Task.sleep(nanoseconds: 500_000_000)
                try await refreshBestMatch()
                isSyncing = false
                syncCompleted = true
                print("✅ ProfileSyncService: Synchronisation réussie après retry")
                
                // Réinitialiser syncCompleted après un court délai
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 secondes
                    syncCompleted = false
                }
            } catch let retryError {
                isSyncing = false
                self.syncError = "AI services temporarily unavailable. Your profile will sync shortly."
                print("❌ ProfileSyncService: Échec après retry: \(retryError.localizedDescription)")
            }
        }
    }
    
    /// Rafraîchit l'analyse AI du profil en utilisant l'endpoint refresh
    private func refreshProfileAnalysis() async throws -> ProfileAnalysisResponse {
        guard let requestUrl = URL(string: Endpoints.aiProfileAnalysisRefresh) else {
            throw NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        guard let token = AuthManager.shared.token else {
            throw NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Missing authentication token"])
        }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = "{}".data(using: .utf8) // Empty JSON body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            if !(200...299).contains(httpResponse.statusCode) {
                let serverMessage = String(decoding: data, as: UTF8.self)
                throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: serverMessage])
            }
        }
        
        do {
            return try JSONDecoder().decode(ProfileAnalysisResponse.self, from: data)
        } catch {
            throw NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to decode profile analysis response"])
        }
    }
    
    /// Rafraîchit la liste Best Match
    private func refreshBestMatch() async throws {
        _ = try await missionService.getBestMatchMissions()
    }
}

