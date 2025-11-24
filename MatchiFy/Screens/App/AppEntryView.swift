import SwiftUI

struct AppEntryView: View {
    @StateObject private var auth = AuthManager.shared
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var hasCompletedOnboarding = false

    private var hasSeenOnboarding: Bool {
        UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    }

    var body: some View {
        Group {
            if auth.isLoggedIn {
                MainTabView()
            } else if hasSeenOnboarding {
                // User has seen onboarding before (or logged out)
                // Always show login screen, never onboarding
                LoginView()
            } else {
                // First time user - show onboarding
                OnboardingView(
                    hasCompletedOnboarding: $hasCompletedOnboarding,
                    onStart: {
                        hasCompletedOnboarding = true
                        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                    }
                )
            }
        }
        .onAppear {
            // Load theme immediately at app launch
            _ = themeManager.currentTheme
            auth.restoreSession()
        }
    }
}

#Preview {
    AppEntryView()
}
