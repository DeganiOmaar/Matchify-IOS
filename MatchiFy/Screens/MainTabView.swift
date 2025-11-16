import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: - Missions Tab
            MissionListView()
                .tabItem {
                    Label("Missions", systemImage: "briefcase.fill")
                }
                .tag(0)
            
            // MARK: - Profile Tab
            RecruiterProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(1)
        }
        .accentColor(.black)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}

