import SwiftUI

struct AlertsView: View {
    @StateObject private var viewModel = AlertsViewModel()
    @State private var selectedAlert: AlertModel? = nil
    @State private var showProposalDetails = false
    @State private var proposalId: String? = nil
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
                        title: "Alerts",
                        onMenuTap: {
                            showProfileDrawer = true
                        },
                        rightButton: (!viewModel.alerts.isEmpty && viewModel.unreadCount > 0) ? {
                            AnyView(
                                Button {
                                    viewModel.markAllAsRead()
                                } label: {
                                    Text("Mark All")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(AppTheme.Colors.primary)
                                }
                            )
                        } : nil
                    )
                    
                    Group {
                        if viewModel.isLoading && viewModel.alerts.isEmpty {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if viewModel.alerts.isEmpty {
                            emptyState
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(viewModel.alerts) { alert in
                                        AlertRowView(alert: alert)
                                            .padding(.horizontal, 20)
                                            .onTapGesture {
                                                handleAlertTap(alert)
                                            }
                                    }
                                }
                                .padding(.vertical, 20)
                            }
                            .refreshable {
                                await viewModel.loadAlerts()
                            }
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
            .navigationDestination(isPresented: $showProposalDetails) {
                if let proposalId = proposalId {
                    ProposalDetailsView(
                        viewModel: ProposalDetailsViewModel(proposalId: proposalId)
                    )
                }
            }
            .navigationDestination(isPresented: $showStats) {
                StatsView()
            }
            .navigationDestination(isPresented: $showProfile) {
                if AuthManager.shared.role == "recruiter" {
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
            .task {
                await viewModel.loadAlerts()
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
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.textSecondary.opacity(0.5))
            
            Text("No Alerts")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text("You're all caught up!")
                .font(.system(size: 16))
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private func handleAlertTap(_ alert: AlertModel) {
        // Mark as read
        viewModel.markAsRead(alertId: alert.alertId)
        
        // Navigate to proposal details
        proposalId = alert.proposalId
        showProposalDetails = true
    }
}

struct AlertRowView: View {
    let alert: AlertModel
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile Image
            profileImageView
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(alert.title)
                        .font(.system(size: 16, weight: alert.isRead ? .regular : .semibold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    // Unread indicator
                    if !alert.isRead {
                        Circle()
                            .fill(AppTheme.Colors.primary)
                            .frame(width: 8, height: 8)
                    }
                }
                
                Text(alert.message)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .lineLimit(2)
                
                HStack {
                    Text(alert.formattedDate)
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.Colors.textSecondary.opacity(0.7))
                    
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(alert.isRead ? AppTheme.Colors.cardBackground : AppTheme.Colors.cardBackground.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            alert.isRead ? Color.clear : AppTheme.Colors.primary.opacity(0.3),
                            lineWidth: 1
                        )
                )
        )
        .shadow(
            color: alert.isRead ? AppTheme.Colors.cardShadow.opacity(0.3) : AppTheme.Colors.cardShadow.opacity(0.5),
            radius: alert.isRead ? 2 : 4,
            x: 0,
            y: 2
        )
    }
    
    private var profileImageView: some View {
        Group {
            if let imageUrl = alert.profileImageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
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
        .frame(width: 50, height: 50)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(
                    alert.isRead ? Color.clear : AppTheme.Colors.primary.opacity(0.5),
                    lineWidth: 2
                )
        )
    }
}

#Preview {
    AlertsView()
}

