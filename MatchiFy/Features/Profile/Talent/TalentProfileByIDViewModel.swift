import Foundation
import Combine

@MainActor
final class TalentProfileByIDViewModel: ObservableObject {
    @Published private(set) var user: UserModel?
    @Published private(set) var portfolio: [ProjectModel] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    
    @Published private(set) var skillNames: [String] = []
    
    private let talentId: String
    private let service = TalentProfileByIDService.shared
    private let skillService = SkillSuggestionService.shared
    
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
                    self.loadSkillNames()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = ErrorHandler.getErrorMessage(from: error, context: .general)
                    self.isLoading = false
                }
            }
        }
    }
    
    private func loadSkillNames() {
        guard let skillIds = user?.skills, !skillIds.isEmpty else {
            skillNames = []
            return
        }
        
        Task { @MainActor in
            do {
                let skills = try await skillService.getSkillsByIds(skillIds)
                self.skillNames = skills.map { $0.name }
            } catch {
                print("Failed to load skill names: \(error.localizedDescription)")
                // Fallback: use IDs if loading names fails
                self.skillNames = skillIds
            }
        }
    }
}

