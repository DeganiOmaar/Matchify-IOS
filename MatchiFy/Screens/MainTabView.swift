import SwiftUI

struct MainTabView: View {
    @StateObject private var auth = AuthManager.shared
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var badgeViewModel = BadgeCountViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: - Missions Tab
            MissionListView()
                .tabItem {
                    Label("Missions", systemImage: "briefcase.fill")
                }
                .tag(0)
            
            // MARK: - Proposals Tab
            ProposalsView()
                .tabItem {
                    Label("Proposals", systemImage: "doc.text.fill")
                }
                .badge(badgeViewModel.isRecruiter && badgeViewModel.proposalsUnreadCount > 0 ? badgeViewModel.proposalsUnreadCount : 0)
                .tag(1)
            
            // MARK: - Messages Tab
            MessagesView()
                .tabItem {
                    Label("Messages", systemImage: "message.fill")
                }
                .badge(badgeViewModel.conversationsWithUnreadCount > 0 ? badgeViewModel.conversationsWithUnreadCount : 0)
                .tag(2)
            
            // MARK: - Alerts Tab
            AlertsView()
                .tabItem {
                    Label("Alerts", systemImage: "bell.fill")
                }
                .badge(badgeViewModel.alertsUnreadCount > 0 ? badgeViewModel.alertsUnreadCount : 0)
                .tag(3)
        }
        .accentColor(AppTheme.Colors.primary)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("AlertsDidUpdate"))) { _ in
            badgeViewModel.loadCounts()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ProposalsDidUpdate"))) { _ in
            badgeViewModel.loadCounts()
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}

