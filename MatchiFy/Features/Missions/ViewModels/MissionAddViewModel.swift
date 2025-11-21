import Foundation
import Combine

final class MissionAddViewModel: ObservableObject {
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
    
    init(service: MissionService? = nil) {
        self.service = service ?? MissionService.shared
    }
    
    // MARK: - Add Skill
    func addSkill() {
        let trimmed = skillInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
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
        Int(filteredBudget) != nil
    }
    
    // MARK: - Create Mission
    @MainActor
    func createMission() {
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
                let request = CreateMissionRequest(
                    title: title,
                    description: description,
                    duration: duration,
                    budget: budgetValue,
                    skills: skills
                )
                
                _ = try await service.createMission(request)
                
                isSaving = false
                saveSuccess = true
                
                // Reset form
                resetForm()
                
            } catch {
                isSaving = false
                errorMessage = extractError(error)
            }
        }
    }
    
    // MARK: - Reset Form
    private func resetForm() {
        title = ""
        description = ""
        duration = ""
        budget = ""
        skillInput = ""
        skills = []
    }
    
    // MARK: - Error Extraction
    private func extractError(_ error: Error) -> String {
        return ErrorHandler.getErrorMessage(from: error, context: .missionCreate)
    }
}

