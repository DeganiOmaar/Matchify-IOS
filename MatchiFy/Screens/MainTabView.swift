import SwiftUI

struct MainTabView: View {
    @StateObject private var auth = AuthManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: - Conditional Tabs based on role
            if auth.role == "recruiter" {
                // Recruiter sees Missions + Profile
                MissionListView()
                    .tabItem {
                        Label("Missions", systemImage: "briefcase.fill")
                    }
                    .tag(0)
                
                RecruiterProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
                    .tag(1)
            } else {
                // Talent sees only Profile
                TalentProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
                    .tag(0)
            }
        }
        .accentColor(.black)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}

