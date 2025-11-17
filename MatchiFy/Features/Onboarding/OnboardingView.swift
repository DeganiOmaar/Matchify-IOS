import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Binding var hasCompletedOnboarding: Bool
    var onStart: () -> Void = {}
    
    var body: some View {
        ZStack {
            Color.white
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
                                .fill(index == viewModel.currentPage ? Color.blue : Color.clear)
                                .frame(width: 10, height: 10)
                                .overlay(
                                    Circle()
                                        .stroke(Color.blue, lineWidth: index == viewModel.currentPage ? 0 : 1.5)
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
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(Color.blue)
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
                                    .foregroundColor(Color.gray)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 55)
                                    .background(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 30)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
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
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 55)
                                    .background(Color.blue)
                                    .cornerRadius(30)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
                .background(Color.white)
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
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.top, 40)
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

#Preview {
    OnboardingView(
        hasCompletedOnboarding: .constant(false),
        onStart: {}
    )
}

