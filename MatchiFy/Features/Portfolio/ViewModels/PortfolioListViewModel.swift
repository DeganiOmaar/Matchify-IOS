import Foundation
import Combine

final class PortfolioListViewModel: ObservableObject {
    @Published var projects: [ProjectModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let service: PortfolioService
    
    init(service: PortfolioService = .shared) {
        self.service = service
    }
    
    func loadProjects() {
        isLoading = true
        errorMessage = nil
        
        Task { @MainActor in
            do {
                print("🔄 Loading portfolio projects...")
                let response = try await service.getAllProjects()
                print("📊 Received \(response.projects.count) projects")
                self.projects = response.projects
                print("✅ Projects loaded: \(self.projects.count)")
                for (index, project) in self.projects.enumerated() {
                    print("   Project \(index + 1): \(project.title) - Media count: \(project.media.count)")
                }
                self.isLoading = false
            } catch {
                print("❌ Error loading projects: \(error)")
                self.isLoading = false
                self.errorMessage = ErrorHandler.getErrorMessage(from: error, context: .general)
            }
        }
    }
    
    func deleteProject(_ project: ProjectModel) {
        Task { @MainActor in
            do {
                try await service.deleteProject(id: project.projectId)
                // Remove from local array
                projects.removeAll { $0.projectId == project.projectId }
                // Notify that portfolio was updated
                NotificationCenter.default.post(name: NSNotification.Name("PortfolioDidUpdate"), object: nil)
            } catch {
                errorMessage = ErrorHandler.getErrorMessage(from: error, context: .portfolioDelete)
            }
        }
    }
}

