import Foundation
import Combine

@MainActor
final class ConversationViewModel: ObservableObject {
    @Published private(set) var messages: [ConversationMessageModel] = []
    @Published private(set) var conversation: ConversationModel?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isSending: Bool = false
    @Published private(set) var errorMessage: String?
    @Published var messageText: String = ""
    
    private let conversationId: String
    private let service: ConversationService
    private let auth = AuthManager.shared
    
    var isRecruiter: Bool {
        auth.role?.lowercased() == "recruiter"
    }
    
    var currentUserId: String? {
        auth.user?.id ?? auth.user?._id
    }
    
    init(
        conversationId: String,
        initialConversation: ConversationModel? = nil,
        service: ConversationService = .shared
    ) {
        self.conversationId = conversationId
        self.service = service
        self.conversation = initialConversation
    }
    
    func loadConversation() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let loaded = try await service.getConversation(id: conversationId)
                await MainActor.run {
                    self.conversation = loaded
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
    
    func loadMessages() {
        Task { [weak self] in
            guard let self else { return }
            do {
                let loaded = try await service.getMessages(conversationId: conversationId)
                await MainActor.run {
                    self.messages = loaded
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = ErrorHandler.getErrorMessage(from: error, context: .general)
                }
            }
        }
    }
    
    func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isSending else { return }
        
        isSending = true
        errorMessage = nil
        
        // Store text before clearing
        let messageToSend = text
        
        // Clear input immediately for better UX
        messageText = ""
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let sent = try await service.sendMessage(conversationId: conversationId, text: messageToSend)
                await MainActor.run {
                    // Add the real message from server
                    if !self.messages.contains(where: { $0.messageId == sent.messageId }) {
                        self.messages.append(sent)
                    }
                    self.isSending = false
                    NotificationCenter.default.post(
                        name: NSNotification.Name("ConversationDidUpdate"),
                        object: nil
                    )
                    NotificationCenter.default.post(
                        name: NSNotification.Name("MessagesDidUpdate"),
                        object: nil
                    )
                }
            } catch {
                await MainActor.run {
                    // Restore text on error
                    self.messageText = messageToSend
                    self.errorMessage = ErrorHandler.getErrorMessage(from: error, context: .general)
                    self.isSending = false
                }
            }
        }
    }
    
    func isMessageFromCurrentUser(_ message: ConversationMessageModel) -> Bool {
        message.senderId == currentUserId
    }
    
    func markAsRead() {
        Task { [weak self] in
            guard let self else { return }
            do {
                _ = try await service.markConversationAsRead(conversationId: conversationId)
                // Notify that messages were updated
                await MainActor.run {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("MessagesDidUpdate"),
                        object: nil
                    )
                    NotificationCenter.default.post(
                        name: NSNotification.Name("ConversationMarkedAsRead"),
                        object: conversationId
                    )
                }
            } catch {
                // Silently fail - marking as read is not critical
                print("Failed to mark conversation as read: \(error.localizedDescription)")
            }
        }
    }
}

