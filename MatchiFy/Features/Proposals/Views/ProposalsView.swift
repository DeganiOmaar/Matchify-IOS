import SwiftUI

struct ProposalsView: View {
    @StateObject private var viewModel = ProposalsViewModel()
    @State private var selectedProposal: ProposalModel? = nil
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tabs (Talent only)
                if !viewModel.isRecruiter {
                    Picker("Tab", selection: $viewModel.selectedTab) {
                        ForEach(ProposalsViewModel.ProposalTab.allCases, id: \.self) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .onChange(of: viewModel.selectedTab) { _, _ in
                        viewModel.loadProposals()
                    }
                    
                    // Mission filter (Talent only)
                    if !viewModel.allMissions.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                Button {
                                    viewModel.selectedMissionId = nil
                                    viewModel.loadProposals()
                                } label: {
                                    Text("Toutes")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(viewModel.selectedMissionId == nil ? .white : AppTheme.Colors.textPrimary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(viewModel.selectedMissionId == nil ? AppTheme.Colors.primary : AppTheme.Colors.secondaryBackground)
                                        )
                                }
                                
                                ForEach(viewModel.allMissions, id: \.self) { missionId in
                                    Button {
                                        viewModel.selectedMissionId = missionId
                                        viewModel.loadProposals()
                                    } label: {
                                        Text(missionId.prefix(8))
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(viewModel.selectedMissionId == missionId ? .white : AppTheme.Colors.textPrimary)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(viewModel.selectedMissionId == missionId ? AppTheme.Colors.primary : AppTheme.Colors.secondaryBackground)
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 12)
                    }
                }
                
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if !viewModel.errorMessage.nilOrEmpty {
                        Text(viewModel.errorMessage ?? "Something went wrong.")
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    } else if viewModel.filteredProposals.isEmpty {
                        emptyState
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.filteredProposals, id: \.proposalId) { proposal in
                                    ProposalCardView(
                                        proposal: proposal,
                                        isRecruiter: viewModel.isRecruiter
                                    )
                                    .padding(.horizontal, 20)
                                    .onTapGesture {
                                        selectedProposal = proposal
                                    }
                                }
                            }
                            .padding(.vertical, 20)
                        }
                    }
                }
            }
            .background(AppTheme.Colors.groupedBackground.ignoresSafeArea())
            .navigationTitle("Proposals")
            .navigationDestination(item: $selectedProposal) { proposal in
                ProposalDetailsView(
                    viewModel: ProposalDetailsViewModel(
                        proposalId: proposal.proposalId,
                        initialProposal: proposal
                    )
                )
            }
            .onAppear {
                viewModel.loadProposals()
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.Colors.textSecondary.opacity(0.4))
            Text("No proposals yet")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            Text(viewModel.isRecruiter ? "You have not received any proposals yet." : "You have not applied to any missions yet.")
                .font(.system(size: 15))
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ProposalCardView: View {
    let proposal: ProposalModel
    let isRecruiter: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(proposal.missionTitle ?? "Mission")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .lineLimit(2)
                
                Spacer()
                
                statusBadge
            }
            
            // Show other user's name (talent name for recruiter, recruiter name for talent)
            if isRecruiter {
                HStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .font(.system(size: 12))
                    Text(proposal.talentFullName ?? "Talent")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            } else if !isRecruiter, let recruiterName = proposal.recruiterName {
                HStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .font(.system(size: 12))
                    Text(recruiterName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
            
            // Short message preview
            Text(proposal.message)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.Colors.textSecondary)
                .lineLimit(3)
            
            HStack {
                Text(proposal.formattedDate)
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                Spacer()
            }
        }
        .padding(16)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(16)
        .shadow(color: AppTheme.Colors.cardShadow, radius: 4, x: 0, y: 2)
    }
    
    private var statusBadge: some View {
        Text(proposal.status.displayName)
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(colorForStatus.opacity(0.9))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(colorForStatus.opacity(0.15))
            .cornerRadius(12)
    }
    
    private var colorForStatus: Color {
        switch proposal.status {
        case .notViewed: return .orange
        case .viewed: return .blue
        case .accepted: return .green
        case .refused: return .red
        }
    }
}

extension Optional where Wrapped == String {
    var nilOrEmpty: Bool {
        guard let value = self else { return true }
        return value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

