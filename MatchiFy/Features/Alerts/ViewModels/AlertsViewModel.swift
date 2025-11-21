import Foundation
import Combine

@MainActor
final class AlertsViewModel: ObservableObject {
    @Published private(set) var alerts: [AlertModel] = []
    @Published private(set) var unreadCount: Int = 0
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isLoadingCount: Bool = false
    @Published private(set) var errorMessage: String?
    
    private let service: AlertService
    private var cancellables = Set<AnyCancellable>()
    
    init(service: AlertService = .shared) {
        self.service = service
    }
    
    func loadAlerts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await service.getAlerts()
            self.alerts = response.alerts
            self.isLoading = false
            // Also refresh unread count
            await loadUnreadCount()
        } catch {
            self.isLoading = false
            self.errorMessage = ErrorHandler.getErrorMessage(from: error, context: .general)
        }
    }
    
    func loadUnreadCount() async {
        isLoadingCount = true
        do {
            let count = try await service.getUnreadCount()
            self.unreadCount = count
            self.isLoadingCount = false
        } catch {
            self.isLoadingCount = false
            // Silently fail - count will remain at current value
            print("Failed to load unread count: \(error.localizedDescription)")
        }
    }
    
    func markAsRead(alertId: String) {
        Task {
            do {
                _ = try await service.markAsRead(alertId: alertId)
                // Update local state
                if let index = alerts.firstIndex(where: { $0.alertId == alertId }) {
                    var updatedAlert = alerts[index]
                    // Create a new alert with isRead = true
                    // Since AlertModel is a struct, we need to create a new one
                    // For now, just reload the alerts
                    await loadAlerts()
                }
                // Refresh unread count
                await loadUnreadCount()
                // Notify badge view model
                NotificationCenter.default.post(name: NSNotification.Name("AlertsDidUpdate"), object: nil)
            } catch {
                print("Failed to mark alert as read: \(error.localizedDescription)")
            }
        }
    }
    
    func markAllAsRead() {
        Task {
            do {
                _ = try await service.markAllAsRead()
                // Reload alerts and count
                await loadAlerts()
                await loadUnreadCount()
                // Notify badge view model
                NotificationCenter.default.post(name: NSNotification.Name("AlertsDidUpdate"), object: nil)
            } catch {
                print("Failed to mark all alerts as read: \(error.localizedDescription)")
            }
        }
    }
}

