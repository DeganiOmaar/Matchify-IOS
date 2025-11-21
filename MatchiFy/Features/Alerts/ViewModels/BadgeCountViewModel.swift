import Foundation
import Combine

@MainActor
final class BadgeCountViewModel: ObservableObject {
    @Published var alertsUnreadCount: Int = 0
    @Published var proposalsUnreadCount: Int = 0
    @Published var conversationsWithUnreadCount: Int = 0
    
    private let alertService = AlertService.shared
    private let proposalService = ProposalService.shared
    private let conversationService = ConversationService.shared
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    
    var isRecruiter: Bool {
        AuthManager.shared.role == "recruiter"
    }
    
    init() {
        loadCounts()
        startPeriodicRefresh()
        observeNotifications()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func loadCounts() {
        Task {
            // Load alerts count
            do {
                let count = try await alertService.getUnreadCount()
                self.alertsUnreadCount = count
            } catch {
                print("Failed to load alerts count: \(error.localizedDescription)")
            }
            
            // Load proposals count (only for recruiters)
            if isRecruiter {
                do {
                    let count = try await proposalService.getUnreadCount()
                    self.proposalsUnreadCount = count
                } catch {
                    print("Failed to load proposals count: \(error.localizedDescription)")
                }
            }
            
            // Load conversations with unread count
            do {
                let count = try await conversationService.getConversationsWithUnreadCount()
                self.conversationsWithUnreadCount = count
            } catch {
                print("Failed to load conversations with unread count: \(error.localizedDescription)")
            }
        }
    }
    
    private func startPeriodicRefresh() {
        // Refresh every 30 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.loadCounts()
            }
        }
    }
    
    private func observeNotifications() {
        NotificationCenter.default.publisher(for: NSNotification.Name("MessagesDidUpdate"))
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.loadCounts()
                }
            }
            .store(in: &cancellables)
    }
}

