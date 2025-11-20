import Foundation

final class FavoriteService {
    static let shared = FavoriteService()
    private init() {}
    
    func addFavorite(missionId: String) async throws -> FavoriteModel {
        try await ApiClient.shared.post(
            url: Endpoints.favorite(missionId: missionId),
            body: EmptyRequest(),
            requiresAuth: true
        )
    }
    
    func removeFavorite(missionId: String) async throws {
        let _: EmptyResponse = try await ApiClient.shared.delete(
            url: Endpoints.favorite(missionId: missionId),
            requiresAuth: true
        )
    }
    
    func getFavorites() async throws -> [MissionModel] {
        let response: MissionsResponse = try await ApiClient.shared.get(
            url: Endpoints.favorites,
            requiresAuth: true
        )
        return response
    }
}

struct EmptyRequest: Codable {}
struct EmptyResponse: Codable {}

