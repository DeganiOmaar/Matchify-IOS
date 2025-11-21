import Foundation
import Combine

@MainActor
final class ProposalsViewModel: ObservableObject {
    @Published private(set) var proposals: [ProposalModel] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    
    private let service: ProposalService
    private var notificationObserver: Any?
    private var auth: AuthManager {
        AuthManager.shared
    }
    
    init(service: ProposalService = .shared) {
        self.service = service
        notificationObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("ProposalDidUpdate"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.loadProposals()
        }
    }
    
    deinit {
        if let observer = notificationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    var isRecruiter: Bool {
        auth.role == "recruiter"
    }
    
    func loadProposals() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetched: [ProposalModel]
                if isRecruiter {
                    fetched = try await service.getRecruiterProposals()
                } else {
                    fetched = try await service.getTalentProposals()
                }
                self.proposals = fetched
                self.isLoading = false
                // Notify badge view model
                NotificationCenter.default.post(name: NSNotification.Name("ProposalsDidUpdate"), object: nil)
            } catch {
                self.isLoading = false
                self.errorMessage = ErrorHandler.getErrorMessage(from: error, context: .general)
            }
        }
    }
}

