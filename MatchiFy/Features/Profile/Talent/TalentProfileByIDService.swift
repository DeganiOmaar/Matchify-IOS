import Foundation

final class TalentProfileByIDService {
    static let shared = TalentProfileByIDService()
    private init() {}
    
    func getTalentProfileById(_ talentId: String) async throws -> (user: UserModel, portfolio: [ProjectModel]) {
        let response: GetUserResponse = try await ApiClient.shared.get(
            url: Endpoints.userById(talentId),
            requiresAuth: true
        )
        return (user: response.user, portfolio: response.portfolio ?? [])
    }
}

