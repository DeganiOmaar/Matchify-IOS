import Foundation

struct MissionFitResponse: Codable {
    let score: Int
    let radar: RadarData
    let shortSummary: String
}

struct RadarData: Codable {
    let skillsMatch: Int
    let experienceFit: Int
    let projectRelevance: Int
    let talentStrengthAlignment: Int
    let overallCoherence: Int
}

