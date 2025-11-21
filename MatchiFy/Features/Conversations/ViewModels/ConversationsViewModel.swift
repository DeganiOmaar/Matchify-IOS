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
                var loaded = try await service.getConversations()
                
                // Load unread count for each conversation
                for index in loaded.indices {
                    do {
                        let unreadCount = try await service.getConversationUnreadCount(conversationId: loaded[index].conversationId)
                        loaded[index].unreadCount = unreadCount
                    } catch {
                        // If fetching unread count fails, set to 0
                        loaded[index].unreadCount = 0
                    }
                }
                
                await MainActor.run {
                    self.conversations = loaded
                    self.isLoading = false
                    // Notify badge view model
                    NotificationCenter.default.post(name: NSNotification.Name("MessagesDidUpdate"), object: nil)
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = ErrorHandler.getErrorMessage(from: error, context: .general)
                    self.isLoading = false
                }
            }
        }
    }
    
    func refreshUnreadCounts() {
        Task { [weak self] in
            guard let self else { return }
            var updatedConversations = self.conversations
            
            // Load unread count for each conversation
            for index in updatedConversations.indices {
                do {
                    let unreadCount = try await service.getConversationUnreadCount(conversationId: updatedConversations[index].conversationId)
                    updatedConversations[index].unreadCount = unreadCount
                } catch {
                    updatedConversations[index].unreadCount = 0
                }
            }
            
            await MainActor.run {
                self.conversations = updatedConversations
                NotificationCenter.default.post(name: NSNotification.Name("MessagesDidUpdate"), object: nil)
            }
        }
    }
    
    func updateConversationUnreadCount(conversationId: String, count: Int) {
        if let index = conversations.firstIndex(where: { $0.conversationId == conversationId }) {
            conversations[index].unreadCount = count
            NotificationCenter.default.post(name: NSNotification.Name("MessagesDidUpdate"), object: nil)
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

