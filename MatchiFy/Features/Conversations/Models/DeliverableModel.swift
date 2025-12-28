import Foundation

struct DeliverableModel: Codable, Identifiable, Hashable {
    let _id: String
    let messageId: String
    let missionId: String
    let senderId: String
    let receiverId: String
    let fileUrl: String?
    let fileType: String?
    let fileName: String?
    let fileSize: Int?
    let type: String? // "file" or "link"
    let url: String? // Unified URL field
    let status: String
    let rejectionReason: String?
    let approvedAt: String?
    let createdAt: String?
    let updatedAt: String?
    
    var id: String { _id }
}
