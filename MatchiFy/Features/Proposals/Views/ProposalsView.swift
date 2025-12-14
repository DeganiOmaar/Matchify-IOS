import SwiftUI

struct ProposalsView: View {
    @StateObject private var viewModel = ProposalsViewModel()
    @State private var selectedProposal: ProposalModel? = nil
    @State private var showProfileDrawer = false
    @State private var showStats = false
    @State private var showProfile = false
    @State private var showSettings = false
    @State private var showTheme = false
    @State private var showCreateOffer = false
    @State private var showBrowseOffers = false
    @State private var showCreateMission = false
    @State private var showMyOffers = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.groupedBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // MARK: - AppBar
                    CustomAppBar(
                        title: "Proposals",
                        profileImageURL: AuthManager.shared.user?.profileImageURL,
                        onProfileTap: {
                            showProfileDrawer = true
                        }
                    )
                
                // Mission Selector (Recruiter only)
                if viewModel.isRecruiter {
                    recruiterMissionSelector
                }
                
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
                    } else if viewModel.isRecruiter && viewModel.selectedMission == nil {
                        // Show placeholder when no mission selected
                        VStack(spacing: 16) {
                            Image(systemName: "list.bullet.rectangle")
                                .font(.system(size: 48))
                                .foregroundColor(AppTheme.Colors.textSecondary.opacity(0.4))
                            Text("Select a mission to view proposals")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.textPrimary)
                            Text("Choose a mission from the dropdown above")
                                .font(.system(size: 15))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if viewModel.filteredProposals.isEmpty {
                        emptyState
                    } else {
                        List {
                            ForEach(viewModel.filteredProposals, id: \.proposalId) { proposal in
                                ProposalCardView(
                                    proposal: proposal,
                                    isRecruiter: viewModel.isRecruiter,
                                    showAiScore: viewModel.aiSortEnabled
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
                
                // MARK: - Left Side Drawer
                if showProfileDrawer {
                    leftDrawer
                        .transition(.move(edge: .leading))
                        .zIndex(1000)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(item: $selectedProposal) { proposal in
                ProposalDetailsView(
                    viewModel: ProposalDetailsViewModel(
                        proposalId: proposal.proposalId,
                        initialProposal: proposal
                    )
                )
            }
            .navigationDestination(isPresented: $showStats) {
                StatsView()
            }
            .navigationDestination(isPresented: $showProfile) {
                if viewModel.isRecruiter {
                    RecruiterProfileView()
                } else {
                    TalentProfileView()
                }
            }
            .navigationDestination(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showTheme) {
                ThemeView()
                    .environmentObject(ThemeManager.shared)
            }
            .sheet(isPresented: $showCreateOffer) {
                CategorySelectionView()
            }
            .sheet(isPresented: $showBrowseOffers) {
                BrowseOffersView()
            }
            .sheet(isPresented: $showCreateMission) {
                MissionAddView(onMissionCreated: {})
            }
            .sheet(isPresented: $showMyOffers) {
                MyOffersView()
            }
            .onAppear {
                if viewModel.isRecruiter {
                    viewModel.loadMissions()
                } else {
                    viewModel.loadProposals()
                }
            }
            .animation(.easeInOut(duration: 0.3), value: showProfileDrawer)
        }
    }
    
    // MARK: - Left Side Drawer
    private var leftDrawer: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background overlay
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showProfileDrawer = false
                        }
                    }
                
                // Drawer content sliding from left
                ProfileDrawerView(
                    onItemSelected: { itemType in
                        // Close drawer first
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showProfileDrawer = false
                        }
                        
                        // Navigate after a short delay for better UX
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            switch itemType {
                            case .myStats:
                                showStats = true
                            case .profile:
                                showProfile = true
                            case .settings:
                                showSettings = true
                            case .theme:
                                showTheme = true
                            case .chatBot:
                                // TODO: Implement chatbot later
                                break
                            case .createOffer:
                                showCreateOffer = true
                            case .myOffers:
                                showMyOffers = true
                            case .browseOffers:
                                showBrowseOffers = true
                            case .createMission:
                                showCreateMission = true
                            }
                        }
                    }
                )
                .frame(width: geometry.size.width * 0.75)
                .frame(maxHeight: .infinity, alignment: .leading)
                .background(AppTheme.Colors.groupedBackground)
                .cornerRadius(20, corners: [.topRight, .bottomRight])
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 5, y: 0)
            }
        }
    }
    
    // MARK: - Recruiter Mission Selector
    
    private var recruiterMissionSelector: some View {
        VStack(spacing: 12) {
            // Mission Dropdown
            Menu {
                ForEach(viewModel.missions) { mission in
                    Button {
                        viewModel.selectedMission = mission
                        viewModel.loadProposals()
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(mission.title)
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                                if !mission.formattedDate.isEmpty {
                                    Text(mission.formattedDate)
                                        .font(.caption)
                                        .foregroundColor(AppTheme.Colors.textSecondary)
                                }
                            }
                            Spacer()
                            
                            // Unviewed count badge
                            if let count = mission.unviewedCount, count > 0 {
                                Text("\(count)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.red)
                                    .clipShape(Capsule())
                            }
                            
                            if viewModel.selectedMission?.missionId == mission.missionId {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppTheme.Colors.primary)
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "briefcase.fill")
                        .foregroundColor(AppTheme.Colors.primary)
                        .font(.system(size: 16))
                    
                    Text(viewModel.selectedMission?.title ?? "Select a mission")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(viewModel.selectedMission != nil ? AppTheme.Colors.textPrimary : AppTheme.Colors.textSecondary)
                    
                    if let mission = viewModel.selectedMission, let count = mission.unviewedCount, count > 0 {
                        Text("\(count)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .clipShape(Capsule())
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .font(.system(size: 14, weight: .semibold))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(AppTheme.Colors.secondaryBackground)
                .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            
            // AI Sort Toggle (only shown when mission is selected)
            if viewModel.selectedMission != nil {
                Button {
                    viewModel.toggleAiSort()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: viewModel.aiSortEnabled ? "sparkles.square.filled.on.square" : "sparkles")
                            .font(.system(size: 16, weight: .semibold))
                        Text(viewModel.aiSortEnabled ? "AI Sorting Enabled" : "Enable AI Sorting")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(viewModel.aiSortEnabled ? .white : AppTheme.Colors.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(viewModel.aiSortEnabled ? AppTheme.Colors.primary : AppTheme.Colors.primary.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 12)
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.Colors.textSecondary.opacity(0.4))
            Text("No proposals yet")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            Text(viewModel.isRecruiter ? "No proposals for this mission yet." : "You have not applied to any missions yet.")
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
    var showAiScore: Bool = false
    
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
            
            // AI Score Badge (shown when AI sorting is enabled and score is available)
            if showAiScore && proposal.hasAiScore {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(proposal.aiScoreColor)
                    Text("AI Match: \(proposal.aiScoreText)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(proposal.aiScoreColor)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(proposal.aiScoreColor.opacity(0.15))
                .cornerRadius(12)
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

