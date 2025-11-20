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
}

