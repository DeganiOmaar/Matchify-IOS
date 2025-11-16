import Foundation
import Combine

final class MissionEditViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var duration: String = ""
    @Published var budget: String = ""
    @Published var skillInput: String = ""
    @Published var skills: [String] = []
    
    @Published var isSaving: Bool = false
    @Published var errorMessage: String? = nil
    @Published var saveSuccess: Bool = false
    
    private let service: MissionService
    private let missionId: String
    
    init(mission: MissionModel, service: MissionService = .shared) {
        self.service = service
        self.missionId = mission.missionId
        
        // Pre-fill form with mission data
        self.title = mission.title
        self.description = mission.description
        self.duration = mission.duration
        self.budget = String(mission.budget)
        self.skills = mission.skills
    }
    
    // MARK: - Add Skill
    func addSkill() {
        let trimmed = skillInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, skills.count < 10 else { return }
        
        if !skills.contains(trimmed) {
            skills.append(trimmed)
            skillInput = ""
        }
    }
    
    // MARK: - Remove Skill
    func removeSkill(_ skill: String) {
        skills.removeAll { $0 == skill }
    }
    
    // MARK: - Validation
    var isFormValid: Bool {
        let filteredBudget = budget.filter { $0.isNumber }
        return !title.isEmpty &&
        !description.isEmpty &&
        !duration.isEmpty &&
        !filteredBudget.isEmpty &&
        !skills.isEmpty &&
        Int(filteredBudget) != nil &&
        skills.count <= 10
    }
    
    // MARK: - Update Mission
    @MainActor
    func updateMission() {
        guard isFormValid else {
            errorMessage = "Veuillez remplir tous les champs requis."
            return
        }
        
        // Filter and validate budget
        let filteredBudget = budget.filter { $0.isNumber }
        guard !filteredBudget.isEmpty, let budgetValue = Int(filteredBudget) else {
            errorMessage = "Le budget doit être un nombre valide."
            return
        }
        
        isSaving = true
        errorMessage = nil
        
        Task {
            do {
                let request = UpdateMissionRequest(
                    title: title,
                    description: description,
                    duration: duration,
                    budget: budgetValue,
                    skills: skills
                )
                
                _ = try await service.updateMission(id: missionId, request)
                
                isSaving = false
                saveSuccess = true
                
            } catch {
                isSaving = false
                errorMessage = extractError(error)
            }
        }
    }
    
    // MARK: - Error Extraction
    private func extractError(_ error: Error) -> String {
        return ErrorHandler.getErrorMessage(from: error, context: .missionUpdate)
    }
}

