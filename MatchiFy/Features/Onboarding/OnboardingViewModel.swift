import Foundation
import Combine

final class OnboardingViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    @Published var hasCompletedOnboarding: Bool = false
    
    private let onboardingKey = "hasSeenOnboarding"
    
    init() {
        // Load onboarding status
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
    }
    
    var isFirstPage: Bool {
        currentPage == 0
    }
    
    var isLastPage: Bool {
        currentPage == 2
    }
    
    func nextPage() {
        if currentPage < 2 {
            currentPage += 1
        }
    }
    
    func previousPage() {
        if currentPage > 0 {
            currentPage -= 1
        }
    }
    
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: onboardingKey)
        hasCompletedOnboarding = true
    }
    
    static func hasSeenOnboarding() -> Bool {
        return UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    }
}

