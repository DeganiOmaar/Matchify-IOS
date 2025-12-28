import Foundation
import Combine

@MainActor
final class ProposalDetailsViewModel: ObservableObject {
    @Published private(set) var proposal: ProposalModel?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var isUpdatingStatus: Bool = false
    
    private let proposalId: String
    private let service: ProposalService
    private let conversationService: ConversationService
    private let auth = AuthManager.shared
    
    @Published var conversation: ConversationModel? = nil
    
    var isRecruiter: Bool {
        auth.role?.lowercased() == "recruiter"
    }
    
    var isTalent: Bool {
        auth.role?.lowercased() == "talent"
    }
    
    init(
        proposalId: String,
        initialProposal: ProposalModel? = nil,
        service: ProposalService = .shared,
        conversationService: ConversationService = .shared
    ) {
        self.proposalId = proposalId
        self.service = service
        self.conversationService = conversationService
        self.proposal = initialProposal
    }
    
    func loadProposal() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let loaded = try await service.getProposal(id: proposalId)
                await MainActor.run {
                    self.proposal = loaded
                    self.isLoading = false
                    // Notify that proposal was viewed (for badge update)
                    NotificationCenter.default.post(name: NSNotification.Name("ProposalsDidUpdate"), object: nil)
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = ErrorHandler.getErrorMessage(from: error, context: .general)
                    self.isLoading = false
                }
            }
        }
    }
    
    func acceptProposal() {
        updateStatus(.accepted)
    }
    
    func refuseProposal(reason: String) {
        updateStatus(.refused, rejectionReason: reason)
    }
    
    private func updateStatus(_ status: ProposalStatus, rejectionReason: String? = nil) {
        guard !isUpdatingStatus, let proposal = proposal else { return }
        isUpdatingStatus = true
        errorMessage = nil
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let updated = try await service.updateStatus(id: proposal.proposalId, status: status, rejectionReason: rejectionReason)
                await MainActor.run {
                    self.proposal = updated
                    self.isUpdatingStatus = false
                    NotificationCenter.default.post(name: NSNotification.Name("ProposalsDidUpdate"), object: nil)
                    NotificationCenter.default.post(
                        name: NSNotification.Name("ProposalDidUpdate"),
                        object: nil
                    )
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = ErrorHandler.getErrorMessage(from: error, context: .general)
                    self.isUpdatingStatus = false
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    var missionTitle: String {
        proposal?.missionTitle ?? "—"
    }
    
    var otherUserName: String {
        if isRecruiter {
            return proposal?.talentFullName ?? "Talent"
        } else {
            return proposal?.recruiterName ?? "Recruiter"
        }
    }
    
    var proposalMessage: String {
        proposal?.message ?? "—"
    }
    
    var formattedDate: String {
        proposal?.formattedDate ?? "—"
    }
    
    var status: ProposalStatus? {
        proposal?.status
    }
    
    var talentId: String? {
        proposal?.talentId
    }
    
    var canShowActions: Bool {
        guard isRecruiter, let status = proposal?.status else { return false }
        return status == .notViewed || status == .viewed
    }
    
    var showMessageButton: Bool {
        guard isRecruiter, let status = proposal?.status else { return false }
        return status == .accepted
    }
    
    var showRefusedIndicator: Bool {
        guard isRecruiter, let status = proposal?.status else { return false }
        return status == .refused
    }
    
    func loadConversation() {
        guard let proposal = proposal, proposal.status == .accepted else { return }
        
        Task { [weak self] in
            guard let self else { return }
            do {
                // Try to find existing conversation
                let conversations = try await conversationService.getConversations()
                let matching = conversations.first { conv in
                    if let convMissionId = conv.missionId {
                        return convMissionId == proposal.missionId &&
                               conv.recruiterId == proposal.recruiterId &&
                               conv.talentId == proposal.talentId
                    } else {
                        return conv.recruiterId == proposal.recruiterId &&
                               conv.talentId == proposal.talentId
                    }
                }
                
                await MainActor.run {
                    if let matching = matching {
                        self.conversation = matching
                    } else {
                        // Create conversation if it doesn't exist
                        Task { [weak self] in
                            guard let self else { return }
                            do {
                                let created = try await conversationService.createConversation(
                                    missionId: proposal.missionId,
                                    talentId: proposal.talentId,
                                    recruiterId: proposal.recruiterId
                                )
                                await MainActor.run {
                                    self.conversation = created
                                }
                            } catch {
                                // Silently fail - conversation might already exist
                            }
                        }
                    }
                }
            } catch {
                // Silently fail - will try to create conversation on message button tap
            }
        }
    }
    
    // MARK: - Mission Details for Completion
    // MARK: - Mission Details for Completion
    // Removed: Talent now completes mission via Chat
    
}

