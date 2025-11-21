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

