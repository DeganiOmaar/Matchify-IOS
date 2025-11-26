import Foundation

final class MissionService {
    static let shared = MissionService()
    private init() {}
    
    // MARK: - Get All Missions (from all recruiters)
    func getAllMissions() async throws -> MissionsResponse {
        return try await ApiClient.shared.get(
            url: Endpoints.allMissions,
            requiresAuth: true
        )
    }
    
    // MARK: - Get Missions by Recruiter
    func getMissionsByRecruiter() async throws -> MissionsResponse {
        return try await ApiClient.shared.get(
            url: Endpoints.missions,
            requiresAuth: true
        )
    }
    
    // MARK: - Get Single Mission
    func getMission(id: String) async throws -> MissionResponse {
        return try await ApiClient.shared.get(
            url: Endpoints.mission(id: id),
            requiresAuth: true
        )
    }
    
    // MARK: - Create Mission
    func createMission(_ request: CreateMissionRequest) async throws -> MissionResponse {
        return try await ApiClient.shared.post(
            url: Endpoints.missions,
            body: request,
            requiresAuth: true
        )
    }
    
    // MARK: - Update Mission
    func updateMission(id: String, _ request: UpdateMissionRequest) async throws -> MissionResponse {
        return try await ApiClient.shared.put(
            url: Endpoints.mission(id: id),
            body: request,
            requiresAuth: true
        )
    }
    
    // MARK: - Delete Mission
    func deleteMission(id: String) async throws -> MissionResponse {
        return try await ApiClient.shared.delete(
            url: Endpoints.mission(id: id),
            requiresAuth: true
        )
    }
    
    // MARK: - Get Best Match Missions
    func getBestMatchMissions() async throws -> BestMatchMissionsResponse {
        return try await ApiClient.shared.get(
            url: Endpoints.bestMatchMissions,
            requiresAuth: true
        )
    }
}

