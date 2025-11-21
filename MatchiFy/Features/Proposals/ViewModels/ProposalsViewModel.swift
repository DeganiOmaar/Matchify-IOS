import Foundation
import Combine

@MainActor
final class ProposalsViewModel: ObservableObject {
    @Published private(set) var proposals: [ProposalModel] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    @Published var selectedTab: ProposalTab = .active
    @Published var selectedMissionId: String? = nil
    @Published var allMissions: [String] = [] // Mission IDs for filter
    
    enum ProposalTab: String, CaseIterable {
        case active = "Active"
        case archive = "Archive"
    }
    
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
    
    var filteredProposals: [ProposalModel] {
        var filtered = proposals
        
        // Filter by tab (for talent only)
        if !isRecruiter {
            filtered = filtered.filter { proposal in
                if selectedTab == .active {
                    return !proposal.isArchived
                } else {
                    return proposal.isArchived
                }
            }
        }
        
        // Filter by mission
        if let missionId = selectedMissionId {
            filtered = filtered.filter { $0.missionId == missionId }
        }
        
        return filtered
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
                    let archived = selectedTab == .archive
                    fetched = try await service.getTalentProposals(
                        missionId: selectedMissionId,
                        archived: selectedTab == .archive ? true : nil
                    )
                }
                self.proposals = fetched
                
                // Extract unique mission IDs for filter
                if !isRecruiter {
                    self.allMissions = Array(Set(fetched.map { $0.missionId }))
                }
                
                self.isLoading = false
                // Notify badge view model
                NotificationCenter.default.post(name: NSNotification.Name("ProposalsDidUpdate"), object: nil)
            } catch {
                self.isLoading = false
                self.errorMessage = ErrorHandler.getErrorMessage(from: error, context: .general)
            }
        }
    }
    
    func archiveProposal(id: String) async {
        do {
            _ = try await service.archiveProposal(id: id)
            await loadProposals()
        } catch {
            self.errorMessage = ErrorHandler.getErrorMessage(from: error, context: .general)
        }
    }
}

