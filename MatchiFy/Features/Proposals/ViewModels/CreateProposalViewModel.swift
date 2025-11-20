import Foundation
import Combine
@MainActor
final class CreateProposalViewModel: ObservableObject {
    @Published var message: String = ""
    @Published var proposedBudget: String = ""
    @Published var estimatedDuration: String = ""
    @Published private(set) var isSubmitting: Bool = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var submissionSuccess: Bool = false
    
    let missionId: String
    let missionTitle: String
    
    private let service: ProposalService
    
    init(
        missionId: String,
        missionTitle: String,
        service: ProposalService = .shared
    ) {
        self.missionId = missionId
        self.missionTitle = missionTitle
        self.service = service
    }
    
    var isFormValid: Bool {
        !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func sendProposal() {
        guard !isSubmitting else { return }
        guard isFormValid else {
            errorMessage = "Please enter a proposal message."
            return
        }
        
        isSubmitting = true
        errorMessage = nil
        
        Task {
            do {
                let request = CreateProposalRequest(
                    missionId: missionId,
                    message: message.trimmingCharacters(in: .whitespacesAndNewlines),
                    proposedBudget: Int(proposedBudget.filter { $0.isNumber }),
                    estimatedDuration: estimatedDuration.isEmpty ? nil : estimatedDuration
                )
                
                _ = try await service.createProposal(request)
                self.submissionSuccess = true
                self.isSubmitting = false
                NotificationCenter.default.post(
                    name: NSNotification.Name("ProposalDidUpdate"),
                    object: nil
                )
            } catch {
                self.isSubmitting = false
                self.errorMessage = ErrorHandler.getErrorMessage(from: error, context: .general)
            }
        }
    }
}

