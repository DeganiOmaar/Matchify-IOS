import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Binding var hasCompletedOnboarding: Bool
    var onStart: () -> Void = {}
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page Content
                TabView(selection: $viewModel.currentPage) {
                    OnboardingPageView(
                        imageName: "onboarding1",
                        title: "Discover the best opportunities based on your talent.",
                        pageIndex: 0
                    )
                    .tag(0)
                    
                    OnboardingPageView(
                        imageName: "onboarding2",
                        title: "Smart matching that connects you with the right recruiters.",
                        pageIndex: 1
                    )
                    .tag(1)
                    
                    OnboardingPageView(
                        imageName: "onboarding3",
                        title: "Start your journey and apply for missions effortlessly.",
                        pageIndex: 2
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .indexViewStyle(.page(backgroundDisplayMode: .never))
                
                // Bottom Section with Dots and Buttons
                VStack(spacing: 24) {
                    // Dot Indicators
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(index == viewModel.currentPage ? AppTheme.Colors.primary : Color.clear)
                                .frame(width: 10, height: 10)
                                .overlay(
                                    Circle()
                                        .stroke(AppTheme.Colors.primary, lineWidth: index == viewModel.currentPage ? 0 : 1.5)
                                )
                        }
                    }
                    .padding(.top, 20)
                    
                    // Navigation Buttons
                    if viewModel.isFirstPage {
                        // First page: centered button
                        Button(action: {
                            viewModel.nextPage()
                        }) {
                            Text("Next")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.buttonText)
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(AppTheme.Colors.primary)
                                .cornerRadius(30)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    } else {
                        // Other pages: Previous and Next/Start buttons
                        HStack(spacing: 16) {
                            // Previous Button
                            Button(action: {
                                viewModel.previousPage()
                            }) {
                                Text("Previous")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 55)
                                    .background(AppTheme.Colors.cardBackground)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 30)
                                            .stroke(AppTheme.Colors.border, lineWidth: 1)
                                    )
                                    .cornerRadius(30)
                            }
                            
                            // Next/Start Button
                            Button(action: {
                                if viewModel.isLastPage {
                                    viewModel.completeOnboarding()
                                    hasCompletedOnboarding = true
                                    // Navigate to Login directly
                                    onStart()
                                } else {
                                    viewModel.nextPage()
                                }
                            }) {
                                Text(viewModel.isLastPage ? "Start" : "Next")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(AppTheme.Colors.buttonText)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 55)
                                    .background(AppTheme.Colors.primary)
                                    .cornerRadius(30)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
                .background(AppTheme.Colors.background)
            }
        }
    }
}

struct OnboardingPageView: View {
    let imageName: String
    let title: String
    let pageIndex: Int
    
    var body: some View {
        VStack(spacing: 0) {
            // Image
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
            
            // Title
            Text(title)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.top, 40)
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.Colors.background)
    }
}

#Preview {
    OnboardingView(
        hasCompletedOnboarding: .constant(false),
        onStart: {}
    )
}

