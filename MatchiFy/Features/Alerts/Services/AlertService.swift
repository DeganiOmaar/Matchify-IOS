import Foundation

final class AlertService {
    static let shared = AlertService()
    private init() {}
    
    func getAlerts(page: Int = 1, limit: Int = 50) async throws -> AlertsResponse {
        guard let url = URL(string: "\(Endpoints.alerts)?page=\(page)&limit=\(limit)") else {
            throw NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        return try await ApiClient.shared.get(
            url: url.absoluteString,
            requiresAuth: true
        )
    }
    
    func getUnreadCount() async throws -> Int {
        let response: UnreadCountResponse = try await ApiClient.shared.get(
            url: Endpoints.alertsUnreadCount,
            requiresAuth: true
        )
        return response.count
    }
    
    func markAsRead(alertId: String) async throws -> AlertModel {
        return try await ApiClient.shared.patch(
            url: Endpoints.alertMarkRead(id: alertId),
            body: EmptyBody(),
            requiresAuth: true
        )
    }
    
    func markAllAsRead() async throws -> Int {
        let response: MarkAllReadResponse = try await ApiClient.shared.patch(
            url: Endpoints.alertsMarkAllRead,
            body: EmptyBody(),
            requiresAuth: true
        )
        return response.count
    }
    
    func getAlert(id: String) async throws -> AlertModel {
        return try await ApiClient.shared.get(
            url: Endpoints.alert(id: id),
            requiresAuth: true
        )
    }
}

// Helper for empty request body
private struct EmptyBody: Codable {}

