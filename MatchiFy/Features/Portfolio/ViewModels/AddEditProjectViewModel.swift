import Foundation
import UIKit
import Combine

final class AddEditProjectViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var role: String = ""
    @Published var description: String = ""
    @Published var skillInput: String = ""
    @Published var skills: [String] = []
    @Published var selectedMedia: MediaItem? = nil
    @Published var existingMediaURL: URL? = nil
    @Published var existingMediaType: String? = nil
    
    @Published var isSaving: Bool = false
    @Published var errorMessage: String? = nil
    @Published var saveSuccess: Bool = false
    
    private let service: PortfolioService
    let projectId: String?
    
    init(project: ProjectModel? = nil, service: PortfolioService = .shared) {
        self.service = service
        self.projectId = project?.projectId
        
        if let project = project {
            self.title = project.title
            self.role = project.role ?? ""
            self.description = project.description ?? ""
            self.skills = project.skills
            self.existingMediaURL = project.mediaURL
            self.existingMediaType = project.mediaType
        }
    }
    
    func addSkill() {
        let trimmed = skillInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        if !skills.contains(trimmed) {
            skills.append(trimmed)
            skillInput = ""
        }
    }
    
    func removeSkill(_ skill: String) {
        skills.removeAll { $0 == skill }
    }
    
    func saveProject() {
        errorMessage = nil
        
        // Validation
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Le titre est requis."
            return
        }
        
        isSaving = true
        
        Task { @MainActor in
            do {
                if let projectId = projectId {
                    // Update existing project
                    let response = try await service.updateProject(
                        id: projectId,
                        title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                        role: role.isEmpty ? nil : role.trimmingCharacters(in: .whitespacesAndNewlines),
                        skills: skills.isEmpty ? nil : skills,
                        description: description.isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines),
                        media: selectedMedia
                    )
                } else {
                    // Create new project
                    let response = try await service.createProject(
                        title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                        role: role.isEmpty ? nil : role.trimmingCharacters(in: .whitespacesAndNewlines),
                        skills: skills.isEmpty ? nil : skills,
                        description: description.isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines),
                        media: selectedMedia
                    )
                }
                
                isSaving = false
                saveSuccess = true
                
            } catch {
                isSaving = false
                errorMessage = ErrorHandler.getErrorMessage(from: error, context: projectId != nil ? .portfolioUpdate : .portfolioCreate)
            }
        }
    }
}

