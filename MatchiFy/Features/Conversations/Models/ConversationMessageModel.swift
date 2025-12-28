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
    let deliverableId: String?
    let deliverable: DeliverableModel?
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
    
    enum CodingKeys: String, CodingKey {
        case id, _id, conversationId, senderId, receiverId, text, isRead, seenAt, contractId, pdfUrl, isContractMessage, deliverableId, createdAt, updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(String.self, forKey: .id)
        _id = try container.decodeIfPresent(String.self, forKey: ._id)
        conversationId = try container.decode(String.self, forKey: .conversationId)
        senderId = try container.decode(String.self, forKey: .senderId)
        receiverId = try container.decodeIfPresent(String.self, forKey: .receiverId)
        text = try container.decode(String.self, forKey: .text)
        isRead = try container.decodeIfPresent(Bool.self, forKey: .isRead)
        seenAt = try container.decodeIfPresent(String.self, forKey: .seenAt)
        pdfUrl = try container.decodeIfPresent(String.self, forKey: .pdfUrl)
        isContractMessage = try container.decodeIfPresent(Bool.self, forKey: .isContractMessage)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        
        // Handle ContractId (String or Object)
        if let contractString = try? container.decodeIfPresent(String.self, forKey: .contractId) {
            contractId = contractString
        } else if let _ = try? container.decodeIfPresent(ContractStub.self, forKey: .contractId) {
             // If it's an object, we assume we can't easily get the ID unless we define a stub
             // For now, set to nil if populated object doesn't match string expected
             contractId = nil
        } else {
            contractId = nil
        }
        
        // Handle DeliverableId (String or Object)
        if let delString = try? container.decodeIfPresent(String.self, forKey: .deliverableId) {
            deliverableId = delString
            deliverable = nil
        } else if let delObject = try? container.decodeIfPresent(DeliverableModel.self, forKey: .deliverableId) {
            deliverable = delObject
            deliverableId = delObject.id
        } else {
            deliverableId = nil
            deliverable = nil
        }
    }
    
    // Helper for encoding (needed because we implemented init(from:))
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(_id, forKey: ._id)
        try container.encode(conversationId, forKey: .conversationId)
        try container.encode(senderId, forKey: .senderId)
        try container.encodeIfPresent(receiverId, forKey: .receiverId)
        try container.encode(text, forKey: .text)
        try container.encodeIfPresent(isRead, forKey: .isRead)
        try container.encodeIfPresent(seenAt, forKey: .seenAt)
        try container.encodeIfPresent(contractId, forKey: .contractId)
        try container.encodeIfPresent(pdfUrl, forKey: .pdfUrl)
        try container.encodeIfPresent(isContractMessage, forKey: .isContractMessage)
        try container.encodeIfPresent(deliverableId, forKey: .deliverableId)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
    }
}

// Stub for decoding populated contract if needed
struct ContractStub: Codable {
    let _id: String
}

