import SwiftUI

struct MissionDetailsView: View {
    @StateObject private var viewModel: MissionDetailsViewModel
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var auth = AuthManager.shared
    @State private var showCreateProposal = false
    
    init(viewModel: MissionDetailsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            topSection
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    summarySection
                    Divider()
                        .background(AppTheme.Colors.border)
                    priceSection
                    skillsSection
                    activitySection
                        .padding(.bottom, 8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(AppTheme.Colors.groupedBackground)
            
            if shouldShowApplyButton {
                applyButton
            }
        }
        .background(AppTheme.Colors.groupedBackground.ignoresSafeArea())
        .overlay(loadingOverlay)
        .overlay(errorOverlay)
        .navigationBarHidden(true)
        .sheet(isPresented: $showCreateProposal) {
            if let mission = viewModel.mission {
                CreateProposalView(
                    viewModel: CreateProposalViewModel(
                        missionId: mission.missionId,
                        missionTitle: mission.title
                    ),
                    onSuccess: {
                        viewModel.loadMission()
                    }
                )
            }
        }
        .onAppear {
            viewModel.loadMission()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ProposalDidUpdate"))) { _ in
            viewModel.loadMission()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("MissionFavoriteDidUpdate"))) { notification in
            if let userInfo = notification.userInfo,
               let missionId = userInfo["missionId"] as? String,
               let isFavorite = userInfo["isFavorite"] as? Bool,
               viewModel.mission?.missionId == missionId {
                // Update the mission's favorite status locally using the ViewModel method
                viewModel.updateMissionFavoriteStatus(isFavorite: isFavorite)
            }
        }
    }
    
    private var shouldShowApplyButton: Bool {
        auth.role?.lowercased() == "talent"
    }
    
    private var canApply: Bool {
        guard let mission = viewModel.mission else { return false }
        return !mission.hasAppliedToMission
    }
    
    private var topSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.primary)
                        .frame(width: 36, height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(AppTheme.Colors.secondaryBackground)
                        )
                }
                Spacer()
                
                // Favorite button for talents
                if shouldShowApplyButton {
                    Button {
                        viewModel.toggleFavorite()
                    } label: {
                        Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 18))
                            .foregroundColor(viewModel.isFavorite ? .red : AppTheme.Colors.textSecondary)
                            .frame(width: 36, height: 36)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(AppTheme.Colors.secondaryBackground)
                            )
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.headerTitle)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                
                Text(viewModel.missionTitle)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(viewModel.postedTimeText)
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 12)
        .background(AppTheme.Colors.groupedBackground)
    }
    
    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Summary")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text(viewModel.summaryText)
                .font(.system(size: 15))
                .foregroundColor(AppTheme.Colors.textPrimary)
                .lineSpacing(4)
        }
    }
    
    private var priceSection: some View {
        HStack(spacing: 12) {
            Image(systemName: "creditcard")
                .font(.system(size: 24))
                .foregroundColor(AppTheme.Colors.primary)
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppTheme.Colors.secondaryBackground)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Budget / Price")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                Text(viewModel.priceText)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }
            
            Spacer()
        }
    }
    
    private var skillsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Skills and Expertise")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            if viewModel.skills.isEmpty {
                Text("No skills specified.")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            } else {
                FlexibleSkillsView(skills: viewModel.skills)
            }
        }
    }
    
    private var activitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Activity on this mission")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            activityRow(title: "Proposals", value: viewModel.proposalsCountText)
            activityRow(title: "Interviewing", value: viewModel.interviewingCountText)
        }
    }
    
    private func activityRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(AppTheme.Colors.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
        }
        .padding(.vertical, 4)
    }
    
    private var applyButton: some View {
        VStack(spacing: 12) {
            Button {
                if canApply {
                    showCreateProposal = true
                }
            } label: {
                Text(canApply ? "Apply to this mission" : "Already applied")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(canApply ? AppTheme.Colors.buttonText : AppTheme.Colors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(canApply ? AppTheme.Colors.primary : AppTheme.Colors.primary.opacity(0.4))
                    .cornerRadius(16)
            }
            .disabled(!canApply)
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            AppTheme.Colors.groupedBackground
                .shadow(color: AppTheme.Colors.cardShadow.opacity(0.3), radius: 6, x: 0, y: -2)
        )
    }
    
    @ViewBuilder
    private var loadingOverlay: some View {
        if viewModel.isLoading && viewModel.mission == nil {
            ZStack {
                AppTheme.Colors.groupedBackground.opacity(0.6)
                    .ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
    }
    
    @ViewBuilder
    private var errorOverlay: some View {
        if let error = viewModel.errorMessage {
            VStack {
                Spacer()
                Text(error)
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .padding()
                    .background(AppTheme.Colors.secondaryBackground)
                    .cornerRadius(12)
                    .padding()
            }
        }
    }
}

private struct FlexibleSkillsView: View {
    let skills: [String]
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8, alignment: .leading)], spacing: 8) {
            ForEach(skills, id: \.self) { skill in
                Text(skill)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(AppTheme.Colors.textSecondary.opacity(0.15))
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

#Preview {
    MissionDetailsView(
        viewModel: MissionDetailsViewModel(
            missionId: "preview",
            initialMission: MissionModel(
                id: "preview",
                _id: "preview",
                title: "Senior iOS Engineer",
                description: "Lead the development of the MatchiFy iOS app with a focus on SwiftUI and modular architecture. Collaborate with designers to ship delightful user experiences.",
                duration: "6 months",
                budget: 60000,
                price: 60000,
                skills: ["SwiftUI", "Combine", "MVVM", "Unit Testing"],
                recruiterId: "123",
                ownerId: "123",
                proposalsCount: 18,
                interviewingCount: 4,
                hasApplied: false,
                isFavorite: false,
                status: "in_progress",
                createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-1800)),
                updatedAt: ISO8601DateFormatter().string(from: Date())
            )
        )
    )
}


