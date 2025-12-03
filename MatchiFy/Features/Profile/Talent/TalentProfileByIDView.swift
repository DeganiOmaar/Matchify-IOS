import SwiftUI

struct TalentProfileByIDView: View {
    @StateObject private var viewModel: TalentProfileByIDViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(talentId: String) {
        _viewModel = StateObject(wrappedValue: TalentProfileByIDViewModel(talentId: talentId))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 100)
                } else if let user = viewModel.user {
                    VStack(spacing: 20) {
                        // MARK: - Banner Image
                        Image("banner")
                            .resizable()
                            .scaledToFill()
                            .frame(height: 220)
                            .clipped()
                            .ignoresSafeArea(edges: .top)
                        
                        // MARK: - Avatar
                        avatarView(user: user)
                            .offset(y: -60)
                            .padding(.bottom, -60)
                        
                        // MARK: - Name
                        Text(user.fullName)
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        
                        // MARK: - Location
                        if let location = user.location, !location.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                                Text(location)
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                                    .font(.system(size: 16))
                            }
                        }
                        
                        // MARK: - Talent Categories
                        if let talents = user.talent, !talents.isEmpty {
                            FlowLayout(spacing: 8) {
                                ForEach(talents, id: \.self) { talent in
                                    Text(talent)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(AppTheme.Colors.primary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(AppTheme.Colors.primary.opacity(0.1))
                                        .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // MARK: - Description
                        if let description = user.description, !description.isEmpty {
                            VStack {
                                Text(description)
                                    .font(.system(size: 15))
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding()
                            }
                            .frame(maxWidth: .infinity)
                            .background(AppTheme.Colors.cardBackground)
                            .cornerRadius(20)
                            .shadow(color: AppTheme.Colors.cardShadow, radius: 8, x: 0, y: 3)
                            .padding(.horizontal, 20)
                        }
                        
                        // MARK: - Skills Card
                        if !viewModel.skillNames.isEmpty {
                            skillsCard(skills: viewModel.skillNames)
                                .padding(.horizontal, 20)
                        }
                        
                        // MARK: - CV File Section
                        if let cvUrl = user.cvUrl, !cvUrl.isEmpty {
                            cvFileSection(cvUrl: cvUrl)
                                .padding(.horizontal, 20)
                        }

                        // MARK: - Portfolio Section (Read-only for recruiters)
                        if !viewModel.portfolio.isEmpty {
                            portfolioSectionView
                                .padding(.horizontal, 20)
                        }
                        
                        Spacer()
                            .frame(height: 20)
                    }
                    .padding(.top, 10)
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Text("Error loading profile")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 100)
                }
            }
            .background(AppTheme.Colors.groupedBackground)
            .ignoresSafeArea(edges: .top)
            .navigationTitle("Talent Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            viewModel.loadProfile()
        }
    }
    
    // MARK: - Avatar View
    private func avatarView(user: UserModel) -> some View {
        Group {
            if let url = user.profileImageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img):
                        img
                            .resizable()
                            .scaledToFill()
                    case .failure, .empty:
                        Image("avatar")
                            .resizable()
                            .scaledToFill()
                    @unknown default:
                        Image("avatar")
                            .resizable()
                            .scaledToFill()
                    }
                }
            } else {
                Image("avatar")
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: 120, height: 120)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.white, lineWidth: 4))
    }
    
    // MARK: - Skills Card
    private func skillsCard(skills: [String]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Skills")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            FlowLayout(spacing: 8) {
                ForEach(skills, id: \.self) { skill in
                    Text(skill)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.Colors.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppTheme.Colors.primary.opacity(0.1))
                        .cornerRadius(16)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(20)
        .shadow(color: AppTheme.Colors.cardShadow, radius: 8, x: 0, y: 3)
    }
    
    // MARK: - Portfolio Section (Read-only)
    private var portfolioSectionView: some View {
        PortfolioGridView(
            projects: viewModel.portfolio,
            onProjectTap: { _ in
                // Read-only: no action on tap for recruiters
                // Could navigate to project detail view if needed
            },
            showAddButton: false,
            onAddProject: nil
        )
    }
    
    // MARK: - CV File Section
    private func cvFileSection(cvUrl: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CV File")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            HStack {
                HStack(spacing: 12) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Text(extractFileName(from: cvUrl))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "eye.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            .padding()
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(12)
            .onTapGesture {
                if let url = URL(string: cvUrl.starts(with: "http") ? cvUrl : Endpoints.baseURL + cvUrl) {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
    
    private func extractFileName(from url: String) -> String {
        return URL(string: url)?.lastPathComponent ?? "CV.pdf"
    }
}

