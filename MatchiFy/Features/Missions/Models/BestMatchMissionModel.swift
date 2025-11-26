import Foundation

struct BestMatchMissionModel: Codable, Identifiable, Hashable {
    let missionId: String
    let title: String
    let description: String
    let duration: String
    let budget: Int
    let skills: [String]
    let recruiterId: String
    let matchScore: Int
    let reasoning: String
    
    var id: String { missionId }
    
    // Convert to MissionModel for compatibility
    func toMissionModel() -> MissionModel {
        return MissionModel(
            id: missionId,
            _id: missionId,
            title: title,
            description: description,
            duration: duration,
            budget: budget,
            price: nil,
            skills: skills,
            recruiterId: recruiterId,
            ownerId: nil,
            proposalsCount: nil,
            interviewingCount: nil,
            hasApplied: nil,
            isFavorite: nil,
            status: nil,
            createdAt: nil,
            updatedAt: nil
        )
    }
}

struct BestMatchMissionsResponse: Codable {
    let missions: [BestMatchMissionModel]
}

