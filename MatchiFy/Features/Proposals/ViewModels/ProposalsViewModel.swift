import Foundation
import Combine

@MainActor
final class ProposalsViewModel: ObservableObject {
    @Published private(set) var proposals: [ProposalModel] = []
    @Published private(set) var missions: [MissionSummaryModel] = []
    @Published var selectedMission: MissionSummaryModel?
    @Published var aiSortEnabled: Bool = false
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    @Published var selectedTab: ProposalTab = .active
    @Published var selectedStatus: ProposalStatusFilter = .all
    
    enum ProposalStatusFilter: String, CaseIterable {
        case all = "All"
        case accepted = "Accepted"
        case refused = "Refused"
        case viewed = "Viewed"
        case notViewed = "Not Viewed"
        
        var apiValue: String? {
            switch self {
            case .all: return nil
            case .accepted: return "ACCEPTED"
            case .refused: return "REFUSED"
            case .viewed: return "VIEWED"
            case .notViewed: return "NOT_VIEWED"
            }
        }
    }
    
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
        
        // Note: Status filtering is now done on the backend
        // This filteredProposals is mainly for tab filtering
        
        return filtered
    }
    
    /// Load missions for recruiter (mission selector)
    func loadMissions() {
        guard isRecruiter else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetched = try await service.getRecruiterMissions()
                self.missions = fetched
                self.isLoading = false
            } catch {
                self.isLoading = false
                self.errorMessage = ErrorHandler.getErrorMessage(from: error, context: .general)
            }
        }
    }
    
    func loadProposals() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetched: [ProposalModel]
                if isRecruiter {
                    // Recruiter must select a mission first
                    guard let mission = selectedMission else {
                        self.proposals = []
                        self.isLoading = false
                        return
                    }
                    
                    // Load proposals for selected mission with optional AI sorting
                    let response = try await service.getProposalsForMission(
                        missionId: mission.missionId,
                        aiSort: aiSortEnabled
                    )
                    fetched = response.proposals
                } else {
                    let archived = selectedTab == .archive
                    // Only apply status filter for active tab
                    let statusFilter = selectedTab == .active ? selectedStatus.apiValue : nil
                    fetched = try await service.getTalentProposals(
                        status: statusFilter,
                        archived: selectedTab == .archive ? true : nil
                    )
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
    
    /// Toggle AI sorting and reload proposals
    func toggleAiSort() {
        aiSortEnabled.toggle()
        loadProposals()
    }
    
    func archiveProposal(id: String) async {
        do {
            _ = try await service.archiveProposal(id: id)
            await loadProposals()
        } catch {
            self.errorMessage = ErrorHandler.getErrorMessage(from: error, context: .general)
        }
    }
    
    func deleteProposal(id: String) async {
        do {
            _ = try await service.deleteProposal(id: id)
            await loadProposals()
        } catch {
            self.errorMessage = ErrorHandler.getErrorMessage(from: error, context: .general)
        }
    }
}

