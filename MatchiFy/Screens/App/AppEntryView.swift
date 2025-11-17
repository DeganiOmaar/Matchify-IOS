import SwiftUI

struct AppEntryView: View {
    @StateObject private var auth = AuthManager.shared
    @State private var hasSeenOnboarding = OnboardingViewModel.hasSeenOnboarding()
    @State private var showLogin = false

    var body: some View {
        Group {
            if auth.isLoggedIn {
                // ✅ User has a persisted session (remember me)
                // MainTabView will show appropriate tabs based on role
                MainTabView()
            } else if showLogin {
                // ✅ Show Login after onboarding
                LoginView()
            } else {
                // ✅ User is not logged in → always show onboarding
                OnboardingView(
                    hasCompletedOnboarding: $hasSeenOnboarding,
                    onStart: {
                        // Navigate to Login when Start button is clicked
                        showLogin = true
                    }
                )
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
