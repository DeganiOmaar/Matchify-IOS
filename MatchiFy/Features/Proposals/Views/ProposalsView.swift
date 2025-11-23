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
                    
                    // Status filter (Talent only, Active tab only)
                    if !viewModel.isRecruiter && viewModel.selectedTab == .active {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(ProposalsViewModel.ProposalStatusFilter.allCases, id: \.self) { statusFilter in
                                    Button {
                                        viewModel.selectedStatus = statusFilter
                                        viewModel.loadProposals()
                                    } label: {
                                        Text(statusFilter.rawValue)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(viewModel.selectedStatus == statusFilter ? .white : AppTheme.Colors.textPrimary)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(viewModel.selectedStatus == statusFilter ? AppTheme.Colors.primary : AppTheme.Colors.secondaryBackground)
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
                        List {
                            ForEach(viewModel.filteredProposals, id: \.proposalId) { proposal in
                                ProposalCardView(
                                    proposal: proposal,
                                    isRecruiter: viewModel.isRecruiter
                                )
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                                .listRowBackground(Color.clear)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedProposal = proposal
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    // Swipe actions only for talent, not for recruiter
                                    if !viewModel.isRecruiter {
                                        // Archive action
                                        Button(role: .none) {
                                            Task {
                                                await viewModel.archiveProposal(id: proposal.proposalId)
                                            }
                                        } label: {
                                            Label("Archive", systemImage: "archivebox")
                                        }
                                        .tint(.blue)
                                        
                                        // Delete action
                                        Button(role: .destructive) {
                                            Task {
                                                await viewModel.deleteProposal(id: proposal.proposalId)
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                        .tint(.red)
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
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

