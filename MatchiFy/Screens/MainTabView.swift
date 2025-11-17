import SwiftUI

struct MainTabView: View {
    @StateObject private var auth = AuthManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: - Both Talent and Recruiter see Missions + Profile
            MissionListView()
                .tabItem {
                    Label("Missions", systemImage: "briefcase.fill")
                }
                .tag(0)
            
            if auth.role == "recruiter" {
                RecruiterProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
                    .tag(1)
            } else {
                TalentProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
                    .tag(1)
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

