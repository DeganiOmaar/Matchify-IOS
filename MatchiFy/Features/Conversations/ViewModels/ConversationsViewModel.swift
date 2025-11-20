import Foundation
import Combine

@MainActor
final class ConversationsViewModel: ObservableObject {
    @Published private(set) var conversations: [ConversationModel] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    
    private let service: ConversationService
    private let auth = AuthManager.shared
    
    var isRecruiter: Bool {
        auth.role?.lowercased() == "recruiter"
    }
    
    init(service: ConversationService = .shared) {
        self.service = service
    }
    
    func loadConversations() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let loaded = try await service.getConversations()
                await MainActor.run {
                    self.conversations = loaded
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = ErrorHandler.getErrorMessage(from: error, context: .general)
                    self.isLoading = false
                }
            }
        }
    }
    
    func getOtherUserId(for conversation: ConversationModel) -> String {
        if isRecruiter {
            return conversation.talentId
        } else {
            return conversation.recruiterId
        }
    }
}

