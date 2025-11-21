import Foundation

struct ConversationMessageModel: Codable, Identifiable, Hashable {
    let id: String?
    let _id: String?
    let conversationId: String
    let senderId: String
    let receiverId: String?
    let text: String
    let isRead: Bool?
    let seenAt: String?
    let contractId: String?
    let pdfUrl: String?
    let isContractMessage: Bool?
    let createdAt: String?
    let updatedAt: String?
    
    var messageId: String {
        if let id, !id.isEmpty { return id }
        if let mongo = _id, !mongo.isEmpty { return mongo }
        return UUID().uuidString
    }
    
    var formattedTime: String {
        guard let createdAt = createdAt else { return "" }
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = iso.date(from: createdAt) {
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        return ""
    }
}

