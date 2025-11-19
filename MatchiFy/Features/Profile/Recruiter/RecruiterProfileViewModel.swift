import Foundation
import Combine

final class RecruiterProfileViewModel: ObservableObject {

    @Published var user: UserModel?
    @Published var joinedText: String = ""
    @Published var projects: [ProjectModel] = []
    @Published var isLoadingProjects: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private let service = RecruiterProfileService.shared
    private let portfolioService = PortfolioService.shared

    init(authManager: AuthManager = .shared) {
        // Load from local first
        self.user = authManager.user
        updateJoinedText()

        // Then load from backend
        loadProfile()
        // Note: Recruiters typically don't have portfolios, but we initialize empty array for UI consistency
        loadProjects()

        authManager.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] usr in
                self?.user = usr
                self?.updateJoinedText()
            }
            .store(in: &cancellables)
    }

    func loadProfile() {
        Task { @MainActor in
            do {
                let response = try await service.getRecruiterProfile()
                self.user = response.user
                AuthManager.shared.persistUpdatedUser(response.user)
                updateJoinedText()
            } catch {
                // Silently fail - keep using local data
                print("Failed to load profile from backend: \(error.localizedDescription)")
            }
        }
    }
    
    func loadProjects() {
        // Recruiters don't have portfolios, but we keep the UI consistent
        // This will result in an empty array, showing the empty state
        isLoadingProjects = true
        
        Task { @MainActor in
            do {
                // Try to load projects (will likely fail for recruiters)
                let response = try await portfolioService.getAllProjects()
                self.projects = response.projects
                self.isLoadingProjects = false
            } catch {
                // Silently fail - projects will remain empty (expected for recruiters)
                print("Portfolio not available for recruiters: \(error.localizedDescription)")
                self.projects = []
                self.isLoadingProjects = false
            }
        }
    }

    private func updateJoinedText() {
        guard let createdAt = user?.createdAt else {
            joinedText = "-"
            return
        }

        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = iso.date(from: createdAt) {
            let f = DateFormatter()
            f.locale = Locale(identifier: "en_US")
            f.dateFormat = "dd MMMM, yyyy"
            joinedText = f.string(from: date)
        } else {
            joinedText = "-"
        }
    }
}
