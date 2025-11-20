import Foundation

struct FavoriteModel: Codable, Identifiable {
    let id: String?
    let _id: String?
    let missionId: String
    let talentId: String
    let createdAt: String?
    let updatedAt: String?
    
    var favoriteId: String {
        if let id, !id.isEmpty { return id }
        if let mongo = _id, !mongo.isEmpty { return mongo }
        return UUID().uuidString
    }
}


