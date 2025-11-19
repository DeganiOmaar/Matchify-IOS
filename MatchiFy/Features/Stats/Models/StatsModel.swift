import Foundation

/// Modèle pour les statistiques de l'utilisateur
struct StatsModel {
    // MARK: - Earnings
    let twelveMonthEarnings: Double
    
    // MARK: - Job Success Score
    let jobSuccessScore: Int? // nil si pas de score
    
    // MARK: - Proposals
    let proposalsSent: Int
    let proposalsViewed: Int
    let interviews: Int
    let hires: Int
    
    // MARK: - Timeframe
    enum Timeframe: String, CaseIterable {
        case last7Days = "Last 7 days"
        case last30Days = "Last 30 days"
        case last90Days = "Last 90 days"
        case last12Months = "Last 12 months"
    }
    
    // MARK: - Initializer
    init(
        twelveMonthEarnings: Double = 0.0,
        jobSuccessScore: Int? = nil,
        proposalsSent: Int = 0,
        proposalsViewed: Int = 0,
        interviews: Int = 0,
        hires: Int = 0
    ) {
        self.twelveMonthEarnings = twelveMonthEarnings
        self.jobSuccessScore = jobSuccessScore
        self.proposalsSent = proposalsSent
        self.proposalsViewed = proposalsViewed
        self.interviews = interviews
        self.hires = hires
    }
    
    // MARK: - Computed Properties
    var hasJobSuccessScore: Bool {
        jobSuccessScore != nil
    }
    
    var formattedEarnings: String {
        String(format: "$%.0f", twelveMonthEarnings)
    }
}

