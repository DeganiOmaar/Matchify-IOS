import Foundation
import Combine

@MainActor
final class ConversationViewModel: ObservableObject {
    @Published private(set) var messages: [ConversationMessageModel] = []
    @Published private(set) var conversation: ConversationModel?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isSending: Bool = false
    @Published private(set) var errorMessage: String?
    @Published var debugLog: String = "Init..."
    @Published var messageText: String = ""
    @Published var showContractSheet: Bool = false
    @Published var mission: MissionModel?
    
    var isTalent: Bool {
        !isRecruiter
    }
    
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
        service: ConversationService? = nil
    ) {
        self.conversationId = conversationId
        self.service = service ?? ConversationService.shared
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
                    
                    if let missionId = loaded.missionId {
                        self.loadMission(id: missionId)
                    }
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
                        object: self.conversationId
                    )
                }
            } catch {
                // Silently fail - marking as read is not critical
                print("Failed to mark conversation as read: \(error.localizedDescription)")
            }
        }
    }
    
    
    func setErrorMessage(_ message: String?) {
        errorMessage = message
    }
    
    // MARK: - Deliverables
    
    func uploadDeliverable(data: Data, fileName: String, mimeType: String) {
        guard !isSending else { return }
        isSending = true
        errorMessage = nil
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let result = try await service.uploadDeliverable(
                    conversationId: conversationId,
                    fileData: data,
                    fileName: fileName,
                    mimeType: mimeType
                )
                
                await MainActor.run {
                    self.messages.append(result.message)
                    self.isSending = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = ErrorHandler.getErrorMessage(from: error, context: .general)
                    self.isSending = false
                }
            }
        }
    }
    
    func submitLink(url: String, title: String?) {
        guard !isSending else { return }
        isSending = true
        errorMessage = nil
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let result = try await service.submitLink(
                    conversationId: conversationId,
                    url: url,
                    title: title
                )
                
                await MainActor.run {
                    self.messages.append(result.message)
                    self.isSending = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = ErrorHandler.getErrorMessage(from: error, context: .general)
                    self.isSending = false
                }
            }
        }
    }
    
    func updateDeliverableStatus(deliverableId: String, status: String, reason: String? = nil) {
        // Prevent concurrent updates
        guard !isLoading else { return }
        isLoading = true
        
        Task { [weak self] in
            guard let self else { return }
            do {
                _ = try await service.updateDeliverableStatus(deliverableId: deliverableId, status: status, reason: reason)
                await MainActor.run {
                    self.isLoading = false
                    // Reload messages to update status in UI
                    self.loadMessages()
                    
                    if status == "approved" {
                        NotificationCenter.default.post(
                            name: NSNotification.Name("DeliverableApproved"),
                            object: nil
                        )
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = ErrorHandler.getErrorMessage(from: error, context: .general)
                    self.isLoading = false
                }
            }
        }
    }
    
    // Deprecated: legacy method, forwarded to new implementation
    func approveDeliverable(deliverableId: String) {
        updateDeliverableStatus(deliverableId: deliverableId, status: "approved")
    }
    
    // MARK: - Payment
    @Published var paymentMission: MissionModel?
    
    // Helper to enforce optional type for SwiftUI views
    var safePaymentMission: MissionModel? {
        return paymentMission
    }
    
    func preparePayment(missionId: String) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await MissionService.shared.getMission(id: missionId)
            await MainActor.run {
                self.paymentMission = response
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = ErrorHandler.getErrorMessage(from: error, context: .general)
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Mission Logic
    func loadMission(id: String) {
        guard !isLoading else { return }
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let loaded = try await MissionService.shared.getMission(id: id)
                await MainActor.run {
                    self.mission = loaded
                }
            } catch {
                print("Failed to load mission context: \(error.localizedDescription)")
            }
        }
    }
}

