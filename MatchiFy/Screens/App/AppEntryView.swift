import SwiftUI

struct AppEntryView: View {
    @StateObject private var auth = AuthManager.shared

    var body: some View {
        Group {
            if auth.isLoggedIn {
                // ✅ User has a persisted session (remember me)
                // Show MainTabView with Missions and Profile tabs
                MainTabView()
            } else {
                // ✅ No session → show Login
                LoginView()
            }
        }
        .onAppear {
            // Check if there is a remembered session
            auth.restoreSession()
        }
    }
}

#Preview {
    AppEntryView()
}
