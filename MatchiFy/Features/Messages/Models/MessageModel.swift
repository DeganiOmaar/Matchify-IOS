import Foundation

/// Modèle pour un message (structure seulement pour l'instant)
struct MessageModel: Identifiable {
    let id: String
    let senderId: String
    let senderName: String
    let senderImage: String?
    let content: String
    let timestamp: Date
    let isUnread: Bool
    let isFavourite: Bool
    
    init(
        id: String = UUID().uuidString,
        senderId: String = "",
        senderName: String = "",
        senderImage: String? = nil,
        content: String = "",
        timestamp: Date = Date(),
        isUnread: Bool = false,
        isFavourite: Bool = false
    ) {
        self.id = id
        self.senderId = senderId
        self.senderName = senderName
        self.senderImage = senderImage
        self.content = content
        self.timestamp = timestamp
        self.isUnread = isUnread
        self.isFavourite = isFavourite
    }
}

