import SwiftUI

struct AppEntryView: View {
    @StateObject private var auth = AuthManager.shared
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var hasCompletedOnboarding = false
    @State private var shouldShowLogin = false

    var body: some View {
        Group {
            if auth.isLoggedIn {
                MainTabView()
            } else if shouldShowLogin {
                LoginView()
            } else {
                OnboardingView(
                    hasCompletedOnboarding: $hasCompletedOnboarding,
                    onStart: {
                        hasCompletedOnboarding = true
                        shouldShowLogin = true
                    }
                )
            }
        }
        .onAppear {
            // Load theme immediately at app launch
            _ = themeManager.currentTheme
            auth.restoreSession()
            if !auth.isLoggedIn {
                resetOnboardingFlow()
            }
        }
        .onChange(of: auth.isLoggedIn) { _, newValue in
            if !newValue {
                resetOnboardingFlow()
            }
        }
    }

    private func resetOnboardingFlow() {
        hasCompletedOnboarding = false
        shouldShowLogin = false
    }
}

#Preview {
    AppEntryView()
}
