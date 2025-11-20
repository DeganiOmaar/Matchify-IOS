import SwiftUI

struct ProposalsView: View {
    @StateObject private var viewModel = ProposalsViewModel()
    @State private var selectedProposal: ProposalModel? = nil
    
    var body: some View {
        NavigationStack {
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
                } else if viewModel.proposals.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.proposals, id: \.proposalId) { proposal in
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

private struct ProposalCardView: View {
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
            if isRecruiter, let talentName = proposal.talentName {
                HStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .font(.system(size: 12))
                    Text(talentName)
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

private extension Optional where Wrapped == String {
    var nilOrEmpty: Bool {
        guard let value = self else { return true }
        return value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

