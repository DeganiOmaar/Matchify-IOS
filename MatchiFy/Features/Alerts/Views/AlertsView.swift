import SwiftUI

struct AlertsView: View {
    @StateObject private var viewModel = AlertsViewModel()
    @State private var selectedAlert: AlertModel? = nil
    @State private var showProposalDetails = false
    @State private var proposalId: String? = nil
    
    var body: some View {
        NavigationStack {
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
            .background(AppTheme.Colors.groupedBackground.ignoresSafeArea())
            .navigationTitle("Alerts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if !viewModel.alerts.isEmpty && viewModel.unreadCount > 0 {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            viewModel.markAllAsRead()
                        } label: {
                            Text("Mark All Read")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(AppTheme.Colors.primary)
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $showProposalDetails) {
                if let proposalId = proposalId {
                    ProposalDetailsView(
                        viewModel: ProposalDetailsViewModel(proposalId: proposalId)
                    )
                }
            }
            .task {
                await viewModel.loadAlerts()
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

