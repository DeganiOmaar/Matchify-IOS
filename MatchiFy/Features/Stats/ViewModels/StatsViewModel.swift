import Foundation
import Combine
import SwiftUI

/// ViewModel pour l'écran Stats
final class StatsViewModel: ObservableObject {
    @Published var stats: StatsModel = StatsModel()
    @Published var selectedTimeframe: StatsModel.Timeframe = .last7Days {
        didSet {
            // Reload stats when timeframe changes
            loadStats()
        }
    }
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
        
        Task { @MainActor in
            do {
                // Map timeframe to days
                let days = mapTimeframeToDays(selectedTimeframe)
                
                // Fetch stats from API
                let statsResponse = try await StatsService.shared.getTalentStats(days: days)
                
                // Update stats model, preserving existing earnings and job success score
                let currentStats = self.stats
                self.stats = StatsModel(
                    twelveMonthEarnings: statsResponse.totalEarnings, // Use real earnings from API
                    jobSuccessScore: currentStats.jobSuccessScore, // Keep existing score
                    proposalsSent: statsResponse.totalProposalsSent,
                    proposalsAccepted: statsResponse.totalProposalsAccepted,
                    proposalsRefused: statsResponse.totalProposalsRefused
                )
                
                self.isLoading = false
            } catch {
                self.errorMessage = "Failed to load stats: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Helper Methods
    private func mapTimeframeToDays(_ timeframe: StatsModel.Timeframe) -> Int {
        switch timeframe {
        case .last7Days:
            return 7
        case .last30Days:
            return 30
        case .last90Days:
            return 90
        case .last12Months:
            return 365
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

