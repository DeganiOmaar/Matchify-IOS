import Foundation
import UIKit
import Combine

final class AddEditProjectViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var role: String = ""
    @Published var description: String = ""
    @Published var skillInput: String = ""
    @Published var skills: [String] = []
    @Published var attachedMedia: [AttachedMediaItem] = []
    @Published var projectLink: String = ""
    @Published var externalLinkInput: String = ""
    @Published var externalLinkTitle: String = ""
    
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
            self.projectLink = project.projectLink ?? ""
            // Convert existing media items to AttachedMediaItem
            self.attachedMedia = project.media.map { .existing($0) }
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
    
    func addMedia(_ media: AttachedMediaItem) {
        attachedMedia.append(media)
    }
    
    func removeMedia(_ media: AttachedMediaItem) {
        attachedMedia.removeAll { $0.id == media.id }
    }
    
    func addExternalLink() {
        let trimmedUrl = externalLinkInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTitle = externalLinkTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedUrl.isEmpty else { return }
        
        // Basic URL validation
        guard URL(string: trimmedUrl) != nil else {
            errorMessage = "Please enter a valid URL"
            return
        }
        
        let link = AttachedMediaItem.externalLink(
            url: trimmedUrl,
            title: trimmedTitle.isEmpty ? trimmedUrl : trimmedTitle
        )
        attachedMedia.append(link)
        externalLinkInput = ""
        externalLinkTitle = ""
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
                // Convert attachedMedia to ProjectMediaItem array and existing MediaItemModel array
                var newMediaItems: [ProjectMediaItem] = []
                var existingMediaItems: [MediaItemModel] = []
                
                for item in attachedMedia {
                    switch item {
                    case .image(let image):
                        newMediaItems.append(.image(image))
                    case .video(let url):
                        newMediaItems.append(.video(url))
                    case .pdf(let url):
                        newMediaItems.append(.pdf(url))
                    case .externalLink(let url, let title):
                        // External links are sent as existing media items
                        let mediaItem = MediaItemModel(
                            type: "external_link",
                            url: nil,
                            title: title,
                            externalLink: url
                        )
                        existingMediaItems.append(mediaItem)
                    case .existing(let mediaItem):
                        // Keep existing media items
                        existingMediaItems.append(mediaItem)
                    }
                }
                
                if let projectId = projectId {
                    // Update existing project
                    let response = try await service.updateProject(
                        id: projectId,
                        title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                        role: role.isEmpty ? nil : role.trimmingCharacters(in: .whitespacesAndNewlines),
                        skills: skills.isEmpty ? nil : skills,
                        description: description.isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines),
                        projectLink: projectLink.isEmpty ? nil : projectLink.trimmingCharacters(in: .whitespacesAndNewlines),
                        mediaItems: newMediaItems,
                        existingMediaItems: existingMediaItems
                    )
                } else {
                    // Create new project
                    let response = try await service.createProject(
                        title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                        role: role.isEmpty ? nil : role.trimmingCharacters(in: .whitespacesAndNewlines),
                        skills: skills.isEmpty ? nil : skills,
                        description: description.isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines),
                        projectLink: projectLink.isEmpty ? nil : projectLink.trimmingCharacters(in: .whitespacesAndNewlines),
                        mediaItems: newMediaItems,
                        existingMediaItems: existingMediaItems
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

