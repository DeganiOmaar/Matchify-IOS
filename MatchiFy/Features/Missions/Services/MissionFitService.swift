import Foundation

final class MissionFitService {
    static let shared = MissionFitService()
    private init() {}
    
    func analyzeMissionFit(missionId: String) async throws -> MissionFitResponse {
        return try await ApiClient.shared.post(
            url: Endpoints.aiMissionFit(missionId: missionId),
            body: EmptyBody(),
            requiresAuth: true
        )
    }
}

