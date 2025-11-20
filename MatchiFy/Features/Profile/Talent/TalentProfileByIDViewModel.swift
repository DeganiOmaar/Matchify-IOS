import Foundation
import Combine

@MainActor
final class TalentProfileByIDViewModel: ObservableObject {
    @Published private(set) var user: UserModel?
    @Published private(set) var portfolio: [ProjectModel] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    
    private let talentId: String
    private let service = TalentProfileByIDService.shared
    
    init(talentId: String) {
        self.talentId = talentId
    }
    
    func loadProfile() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let result = try await service.getTalentProfileById(self.talentId)
                await MainActor.run {
                    self.user = result.user
                    self.portfolio = result.portfolio
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = ErrorHandler.getErrorMessage(from: error, context: .general)
                    self.isLoading = false
                }
            }
        }
    }
}

