import SwiftUI

struct MissionListView: View {
    @StateObject private var vm = MissionListViewModel()
    @StateObject private var auth = AuthManager.shared
    @State private var showAddMission = false
    @State private var selectedMission: MissionModel? = nil
    @State private var showEditMission = false
    @State private var showDeleteAlert = false
    @State private var missionToDelete: MissionModel? = nil
    @State private var showStats = false
    @State private var showProfile = false
    @State private var showSettings = false
    @State private var showTheme = false
    @State private var missionDetailsSelection: MissionModel? = nil
    @State private var showMissionProposals: Bool = false
    @State private var selectedMissionForProposals: MissionModel? = nil
    @State private var showCreateOffer = false
    @State private var showBrowseOffers = false
    @State private var showCreateMission = false
    @State private var showMyOffers = false
    
    private var isRecruiter: Bool {
        auth.role == "recruiter"
    }
    
    private var isTalent: Bool {
        auth.role == "talent"
    }
    
    private var visibleTabs: [MissionListViewModel.MissionTab] {
        if isTalent {
            return MissionListViewModel.MissionTab.allCases
        }
        return []
    }
    
    @ViewBuilder
    private var profileView: some View {
        if isRecruiter {
            RecruiterProfileView()
        } else {
            TalentProfileView()
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.groupedBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // MARK: - AppBar
                    CustomAppBar(
                        title: "Missions",
                        onMenuTap: {
                            vm.showProfileDrawer = true
                        },
                        rightButton: isRecruiter ? {
                            AnyView(
                                Button {
                                    showAddMission = true
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(AppTheme.Colors.primary)
                                }
                            )
                        } : nil
                    )
                    
                    // MARK: - Search Bar
                    searchBar
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    
                    // MARK: - Tabs (Talent only)
                    if isTalent {
                        tabsView
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                    }
                    
                    // MARK: - Missions List
                    if (vm.isLoading || (vm.selectedTab == .favorites && vm.isLoadingFavorites) || (vm.selectedTab == .bestMatches && vm.isLoadingBestMatches)) && vm.filteredMissions.isEmpty {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.5)
                        Spacer()
                    } else if vm.filteredMissions.isEmpty {
                        emptyStateView
                    } else {
                        missionsList
                    }
                }
                
                // MARK: - Left Side Drawer
                if vm.showProfileDrawer {
                    leftDrawer
                        .transition(.move(edge: .leading))
                        .zIndex(1000)
                }
            }
            .navigationBarHidden(true)
            .refreshable {
                await vm.refreshMissions()
            }
            .onAppear {
                vm.loadMissions()
            }
            .onChange(of: vm.selectedTab) { _, newTab in
                if isTalent {
                    Task {
                        if newTab == .favorites {
                            await vm.loadFavorites()
                        } else if newTab == .bestMatches {
                            await vm.loadBestMatches()
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddMission) {
                MissionAddView(onMissionCreated: {
                    vm.loadMissions()
                })
            }
            .navigationDestination(isPresented: $showEditMission) {
                if let mission = selectedMission {
                    MissionEditView(mission: mission, onMissionUpdated: {
                        vm.loadMissions()
                    })
                }
            }
            .navigationDestination(isPresented: $showStats) {
                StatsView()
            }
            .navigationDestination(isPresented: $showProfile) {
                profileView
            }
            .navigationDestination(isPresented: $showSettings) {
                SettingsView()
            }
            .navigationDestination(item: $missionDetailsSelection) { mission in
                MissionDetailsView(
                    viewModel: MissionDetailsViewModel(
                        missionId: mission.missionId,
                        initialMission: mission
                    )
                )
            }
            .sheet(isPresented: $showTheme) {
                ThemeView()
                    .environmentObject(ThemeManager.shared)
            }
            .navigationDestination(isPresented: $showMissionProposals) {
                if let mission = selectedMissionForProposals {
                    MissionProposalsView(
                        missionId: mission.missionId,
                        missionTitle: mission.title
                    )
                }
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
            .alert("Delete Mission", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {
                    missionToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let mission = missionToDelete {
                        vm.deleteMission(mission)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this mission? This action cannot be undone.")
            }
            .animation(.easeInOut(duration: 0.3), value: vm.showProfileDrawer)
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
                            vm.showProfileDrawer = false
                        }
                    }
                
                // Drawer content sliding from left
                ProfileDrawerView(
                    onItemSelected: { itemType in
                        // Fermer le drawer d'abord
                        withAnimation(.easeInOut(duration: 0.3)) {
                            vm.showProfileDrawer = false
                        }
                        
                        // Naviguer après un court délai pour une meilleure UX
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
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            TextField(text: $vm.searchText) {
                Text("Search")
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
                .font(.system(size: 15))
                .foregroundColor(AppTheme.Colors.textPrimary)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            
            if !vm.searchText.isEmpty {
                Button {
                    vm.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.Colors.border, lineWidth: 1)
        )
    }
    
    // MARK: - Tabs View
    private var tabsView: some View {
        HStack(spacing: 0) {
            ForEach(visibleTabs, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        vm.selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 0) {
                        Text(tab.rawValue)
                            .font(.system(size: 15, weight: vm.selectedTab == tab ? .semibold : .regular))
                            .foregroundColor(vm.selectedTab == tab ? AppTheme.Colors.primary : AppTheme.Colors.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        
                        // Underline indicator
                        Rectangle()
                            .fill(vm.selectedTab == tab ? AppTheme.Colors.primary : Color.clear)
                            .frame(height: 2)
                    }
                }
            }
        }
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(8)
    }
    
    // MARK: - Missions List
    private var missionsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(vm.filteredMissions, id: \.missionId) { mission in
                    let bestMatchInfo = vm.getBestMatchInfo(for: mission.missionId)
                    MissionCardViewNew(
                        mission: mission,
                        action: missionCardAction(for: mission),
                        onTap: {
                            missionDetailsSelection = mission
                        },
                        matchScore: bestMatchInfo?.matchScore,
                        reasoning: bestMatchInfo?.reasoning,
                        showAIMatchBadge: vm.selectedTab == .bestMatches && bestMatchInfo != nil
                    )
                    .padding(.horizontal, 20)
                }
            }
            .padding(.vertical, 20)
            .padding(.bottom, 20) // Extra padding for tab bar
        }
    }
    
    // MARK: - Mission Card Action
    private func missionCardAction(for mission: MissionModel) -> MissionCardViewNew.Action? {
        if isRecruiter {
            guard vm.isMissionOwner(mission) else { return nil }
            return .ownerMenu(
                onEdit: { handleEdit(mission: mission) },
                onDelete: { handleDelete(mission: mission) },
                onViewProposals: { handleViewProposals(mission: mission) }
            )
        } else if isTalent {
            return .favorite(
                isFavorite: { vm.isFavorite(mission) },
                toggle: { vm.toggleFavorite(mission) }
            )
        }
        return nil
    }
    
    private func handleViewProposals(mission: MissionModel) {
        selectedMissionForProposals = mission
        showMissionProposals = true
    }
    
    private func handleEdit(mission: MissionModel) {
        selectedMission = mission
        showEditMission = true
    }
    
    private func handleDelete(mission: MissionModel) {
        missionToDelete = mission
        showDeleteAlert = true
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "briefcase")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.textSecondary.opacity(0.5))
            
            Text("No missions yet")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            // Role-based subtext
            if isRecruiter {
                Text("Create your first mission offer to get started")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.Colors.textSecondary.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            } else if isTalent {
                if vm.selectedTab == .bestMatches {
                    VStack(spacing: 12) {
                        Text("No matching missions available yet.")
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.Colors.textSecondary.opacity(0.8))
                            .multilineTextAlignment(.center)
                        
                        Text("To get personalized matches:\n1. Complete your profile\n2. Add your skills\n3. Run AI profile analysis")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.Colors.textSecondary.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.horizontal, 40)
                } else {
                    Text("You can save your favourite or wait until there a new missions for best match and most recent missions")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.Colors.textSecondary.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            }
            
            // Only show button for Recruiters
            if isRecruiter {
                Button {
                    showAddMission = true
                } label: {
                    Text("Create Mission")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.buttonText)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(AppTheme.Colors.primary)
                        .cornerRadius(14)
                }
                .padding(.top, 10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// Preview removed - all data is dynamic from backend

