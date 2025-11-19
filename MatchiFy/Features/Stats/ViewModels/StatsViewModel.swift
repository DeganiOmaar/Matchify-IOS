import Foundation
import Combine
import SwiftUI

/// ViewModel pour l'écran Stats
final class StatsViewModel: ObservableObject {
    @Published var stats: StatsModel = StatsModel()
    @Published var selectedTimeframe: StatsModel.Timeframe = .last7Days
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // MARK: - Initializer
    init() {
        loadStats()
    }
    
    // MARK: - Load Stats
    func loadStats() {
        isLoading = true
        errorMessage = nil
        
        // TODO: Remplacer par un appel API réel plus tard
        // Pour l'instant, on utilise des données mock
        Task { @MainActor in
            // Simuler un délai de chargement
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 secondes
            
            // Données mock
            self.stats = StatsModel(
                twelveMonthEarnings: 0.0,
                jobSuccessScore: nil,
                proposalsSent: 0,
                proposalsViewed: 0,
                interviews: 0,
                hires: 0
            )
            
            self.isLoading = false
        }
    }
    
    // MARK: - Computed Properties
    var formattedEarnings: String {
        stats.formattedEarnings
    }
    
    var hasJobSuccessScore: Bool {
        stats.hasJobSuccessScore
    }
    
    var jobSuccessScoreText: String {
        if let score = stats.jobSuccessScore {
            return "\(score)"
        }
        return "–"
    }
    
    var proposalsSentText: String {
        if stats.proposalsSent == 1 {
            return "\(stats.proposalsSent) proposal sent"
        }
        return "\(stats.proposalsSent) proposals sent"
    }
}

