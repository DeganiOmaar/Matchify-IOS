import Foundation
import Combine
@MainActor
final class CreateProposalViewModel: ObservableObject {
    @Published var message: String = ""
    @Published var proposalContent: String = ""
    @Published var proposedBudget: String = ""
    @Published var estimatedDuration: String = ""
    @Published private(set) var isSubmitting: Bool = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var submissionSuccess: Bool = false
    @Published private(set) var isGeneratingAI: Bool = false
    
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
        let trimmed = proposalContent.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count >= 200
    }
    
    func sendProposal() {
        guard !isSubmitting else { return }
        guard isFormValid else {
            errorMessage = "La proposition doit contenir au moins 200 caractères."
            return
        }
        
        isSubmitting = true
        errorMessage = nil
        
        Task {
            do {
                let request = CreateProposalRequest(
                    missionId: missionId,
                    message: message.isEmpty ? nil : message.trimmingCharacters(in: .whitespacesAndNewlines),
                    proposalContent: proposalContent.trimmingCharacters(in: .whitespacesAndNewlines),
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
    
    private var generationTask: Task<Void, Never>?
    
    func generateWithAI() {
        print("🚀 [VM] generateWithAI called")
        
        guard !isGeneratingAI else {
            print("⚠️ [VM] Already generating, ignoring")
            return
        }
        
        print("🔵 [VM] Starting generation, missionId: \(missionId)")
        isGeneratingAI = true
        errorMessage = nil
        proposalContent = "" // Clear existing content
        
        generationTask = Task {
            print("🔵 [VM] Task started, creating stream...")
            var chunkCount = 0
            
            for await chunk in service.generateProposalContentStream(missionId: missionId) {
                chunkCount += 1
                print("📝 [VM] Chunk #\(chunkCount) received: \(chunk.prefix(50))...")
                
                // Check if task was cancelled
                if Task.isCancelled {
                    print("⚠️ [VM] Task cancelled")
                    break
                }
                
                await MainActor.run {
                    self.proposalContent += chunk
                }
            }
            
            print("✅ [VM] Stream ended, total chunks: \(chunkCount)")
            
            await MainActor.run {
                self.isGeneratingAI = false
                if chunkCount == 0 {
                    self.errorMessage = "Aucun contenu généré. Veuillez réessayer."
                }
            }
        }
    }
    
    func cancelGeneration() {
        print("🛑 [VM] Cancelling generation")
        generationTask?.cancel()
        generationTask = nil
        isGeneratingAI = false
    }
}

