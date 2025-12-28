import Foundation

final class ConversationService {
    static let shared = ConversationService()
    private init() {}
    
    func getConversations() async throws -> [ConversationModel] {
        try await ApiClient.shared.get(
            url: Endpoints.conversations,
            requiresAuth: true
        )
    }
    
    func getConversation(id: String) async throws -> ConversationModel {
        try await ApiClient.shared.get(
            url: Endpoints.conversation(id: id),
            requiresAuth: true
        )
    }
    
    func getMessages(conversationId: String) async throws -> [ConversationMessageModel] {
        try await ApiClient.shared.get(
            url: Endpoints.conversationMessages(id: conversationId),
            requiresAuth: true
        )
    }
    
    func sendMessage(conversationId: String, text: String) async throws -> ConversationMessageModel {
        try await ApiClient.shared.post(
            url: Endpoints.conversationMessages(id: conversationId),
            body: CreateMessageRequest(text: text),
            requiresAuth: true
        )
    }
    
    func createConversation(
        missionId: String? = nil,
        talentId: String? = nil,
        recruiterId: String? = nil
    ) async throws -> ConversationModel {
        try await ApiClient.shared.post(
            url: Endpoints.conversations,
            body: CreateConversationRequest(
                missionId: missionId,
                talentId: talentId,
                recruiterId: recruiterId
            ),
            requiresAuth: true
        )
    }
    
    func getUnreadCount() async throws -> Int {
        let response: UnreadMessagesCountResponse = try await ApiClient.shared.get(
            url: Endpoints.conversationsUnreadCount,
            requiresAuth: true
        )
        return response.count
    }
    
    func getConversationsWithUnreadCount() async throws -> Int {
        let response: ConversationsWithUnreadCountResponse = try await ApiClient.shared.get(
            url: Endpoints.conversationsWithUnread,
            requiresAuth: true
        )
        return response.count
    }
    
    func getConversationUnreadCount(conversationId: String) async throws -> Int {
        let response: ConversationUnreadCountResponse = try await ApiClient.shared.get(
            url: Endpoints.conversationUnreadCount(id: conversationId),
            requiresAuth: true
        )
        return response.count
    }
    
    func markConversationAsRead(conversationId: String) async throws -> MarkConversationReadResponse {
        return try await ApiClient.shared.post(
            url: Endpoints.conversationMarkRead(id: conversationId),
            body: EmptyBody(),
            requiresAuth: true
        )
    }
    
    func deleteConversation(conversationId: String) async throws -> ConversationModel {
        return try await ApiClient.shared.delete(
            url: Endpoints.conversationDelete(id: conversationId),
            requiresAuth: true
        )
    }
    
    func uploadDeliverable(conversationId: String, fileData: Data, fileName: String, mimeType: String) async throws -> (message: ConversationMessageModel, deliverable: DeliverableModel) {
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        struct UploadDeliverableResponse: Codable {
            let message: ConversationMessageModel
            let deliverable: DeliverableModel
        }
        
        let response: UploadDeliverableResponse = try await ApiClient.shared.upload(
            url: Endpoints.uploadDeliverable(id: conversationId),
            data: body,
            boundary: boundary,
            headers: ["Content-Type": "multipart/form-data; boundary=\(boundary)"],
            requiresAuth: true
        )
        return (message: response.message, deliverable: response.deliverable)
    }
    
    func updateDeliverableStatus(deliverableId: String, status: String, reason: String? = nil) async throws -> DeliverableModel {
        struct statusBody: Codable {
            let status: String
            let reason: String?
        }
        
        return try await ApiClient.shared.patch(
            url: Endpoints.updateDeliverableStatus(id: deliverableId),
            body: statusBody(status: status, reason: reason),
            requiresAuth: true
        )
    }
    
    func submitLink(conversationId: String, url: String, title: String?) async throws -> (message: ConversationMessageModel, deliverable: DeliverableModel) {
        struct SubmitLinkRequest: Codable {
            let url: String
            let title: String?
        }
        
        struct SubmitLinkResponse: Codable {
            let message: ConversationMessageModel
            let deliverable: DeliverableModel
        }
        
        let response: SubmitLinkResponse = try await ApiClient.shared.post(
            url: Endpoints.submitDeliverableLink(id: conversationId),
            body: SubmitLinkRequest(url: url, title: title),
            requiresAuth: true
        )
        return (message: response.message, deliverable: response.deliverable)
    }
}

struct UnreadMessagesCountResponse: Codable {
    let count: Int
}

struct ConversationsWithUnreadCountResponse: Codable {
    let count: Int
}

struct ConversationUnreadCountResponse: Codable {
    let count: Int
}

struct MarkConversationReadResponse: Codable {
    let count: Int
}
