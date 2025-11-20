import SwiftUI

struct MainTabView: View {
    @StateObject private var auth = AuthManager.shared
    @EnvironmentObject private var themeManager: ThemeManager
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
                .tag(1)
            
            // MARK: - Messages Tab
            MessagesView()
                .tabItem {
                    Label("Messages", systemImage: "message.fill")
                }
                .tag(2)
        }
        .accentColor(AppTheme.Colors.primary)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}

