import Foundation

final class TalentProfileByIDService {
    static let shared = TalentProfileByIDService()
    private init() {}
    
    func getTalentProfileById(_ talentId: String) async throws -> UserModel {
        let response: GetUserResponse = try await ApiClient.shared.get(
            url: Endpoints.userById(talentId),
            requiresAuth: true
        )
        return response.user
    }
}

