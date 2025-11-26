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
    let missionRequirementsFit: Int
    let softSkillsFit: Int
    // Legacy fields for backward compatibility
    let talentStrengthAlignment: Int?
    let overallCoherence: Int?
    
    enum CodingKeys: String, CodingKey {
        case skillsMatch
        case experienceFit
        case projectRelevance
        case missionRequirementsFit
        case softSkillsFit
        case talentStrengthAlignment
        case overallCoherence
    }
    
    // Public initializer for creating instances directly
    init(
        skillsMatch: Int,
        experienceFit: Int,
        projectRelevance: Int,
        missionRequirementsFit: Int,
        softSkillsFit: Int,
        talentStrengthAlignment: Int? = nil,
        overallCoherence: Int? = nil
    ) {
        self.skillsMatch = skillsMatch
        self.experienceFit = experienceFit
        self.projectRelevance = projectRelevance
        self.missionRequirementsFit = missionRequirementsFit
        self.softSkillsFit = softSkillsFit
        self.talentStrengthAlignment = talentStrengthAlignment
        self.overallCoherence = overallCoherence
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        skillsMatch = try container.decode(Int.self, forKey: .skillsMatch)
        experienceFit = try container.decode(Int.self, forKey: .experienceFit)
        projectRelevance = try container.decode(Int.self, forKey: .projectRelevance)
        
        // Try to decode new field names, fallback to old ones if not present
        if let missionReqFit = try? container.decode(Int.self, forKey: .missionRequirementsFit) {
            missionRequirementsFit = missionReqFit
        } else if let overall = try? container.decodeIfPresent(Int.self, forKey: .overallCoherence) {
            missionRequirementsFit = overall ?? 0
        } else {
            missionRequirementsFit = 0
        }
        
        if let softSkills = try? container.decode(Int.self, forKey: .softSkillsFit) {
            softSkillsFit = softSkills
        } else if let strengthAlign = try? container.decodeIfPresent(Int.self, forKey: .talentStrengthAlignment) {
            softSkillsFit = strengthAlign ?? 0
        } else {
            softSkillsFit = 0
        }
        
        // Legacy fields (optional)
        talentStrengthAlignment = try? container.decodeIfPresent(Int.self, forKey: .talentStrengthAlignment)
        overallCoherence = try? container.decodeIfPresent(Int.self, forKey: .overallCoherence)
    }
}

