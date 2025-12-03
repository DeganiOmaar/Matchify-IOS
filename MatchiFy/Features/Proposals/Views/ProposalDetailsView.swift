import SwiftUI

struct ProposalDetailsView: View {
    @StateObject private var viewModel: ProposalDetailsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showTalentProfile = false
    @State private var showConversation = false
    @State private var showRejectAlert = false
    @State private var rejectionReason = ""
    
    init(viewModel: ProposalDetailsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            topSection
            
            if viewModel.isLoading && viewModel.proposal == nil {
                Spacer()
                ProgressView()
                Spacer()
            } else if let proposal = viewModel.proposal {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        missionTitleSection
                        otherUserSection
                        messageSection
                        proposalContentSection
                        dateSection
                        statusSection
                            .padding(.bottom, 8)
                        
                        if let reason = viewModel.proposal?.rejectionReason, !reason.isEmpty, viewModel.proposal?.status == .refused {
                            rejectionReasonSection(reason: reason)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
                .background(AppTheme.Colors.groupedBackground)
                
                if viewModel.isRecruiter {
                    bottomActionsSection
                }
            } else {
                Spacer()
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                Spacer()
            }
        }
        .background(AppTheme.Colors.groupedBackground.ignoresSafeArea())
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar) // Hide bottom tab bar
        .onAppear {
            viewModel.loadProposal()
            if viewModel.showMessageButton {
                viewModel.loadConversation()
            }
        }
        .onChange(of: viewModel.proposal?.status) { _, newStatus in
            if newStatus == .accepted {
                viewModel.loadConversation()
            }
        }
        .navigationDestination(isPresented: $showTalentProfile) {
            if let talentId = viewModel.talentId {
                TalentProfileByIDView(talentId: talentId)
            }
        }
        .navigationDestination(isPresented: $showConversation) {
            if let conversation = viewModel.conversation {
                ConversationView(
                    viewModel: ConversationViewModel(
                        conversationId: conversation.conversationId,
                        initialConversation: conversation
                    )
                )
            }
        }
        .alert("Reject Proposal", isPresented: $showRejectAlert) {
            TextField("Rejection Reason", text: $rejectionReason)
            Button("Cancel", role: .cancel) {
                rejectionReason = ""
            }
            Button("Reject", role: .destructive) {
                if !rejectionReason.isEmpty {
                    viewModel.refuseProposal(reason: rejectionReason)
                    rejectionReason = ""
                }
            }
        } message: {
            Text("Please provide a reason for rejecting this proposal.")
        }
    }
    
    // MARK: - Top Section
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
            }
            
            Text("Proposal Details")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppTheme.Colors.textPrimary)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 12)
        .background(AppTheme.Colors.groupedBackground)
    }
    
    // MARK: - Mission Title Section
    private var missionTitleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mission")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            Text(viewModel.missionTitle)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
        }
    }
    
    // MARK: - Other User Section
    private var otherUserSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.isRecruiter ? "Talent" : "Recruiter")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            if viewModel.isRecruiter {
                Button {
                    showTalentProfile = true
                } label: {
                    HStack(spacing: 8) {
                        Text(viewModel.otherUserName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.primary)
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                }
            } else {
                Text(viewModel.otherUserName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }
        }
    }
    
    // MARK: - Message Section
    private var messageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cover Letter")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            Text(viewModel.proposalMessage)
                .font(.system(size: 16))
                .foregroundColor(AppTheme.Colors.textPrimary)
                .lineSpacing(4)
        }
    }
    
    // MARK: - Proposal Content Section
    @ViewBuilder
    private var proposalContentSection: some View {
        if let proposal = viewModel.proposal, let proposalContent = proposal.proposalContent, !proposalContent.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Proposal")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                
                Text(proposalContent)
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .lineSpacing(4)
            }
        }
    }
    
    // MARK: - Date Section
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sent")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            Text(viewModel.formattedDate)
                .font(.system(size: 16))
                .foregroundColor(AppTheme.Colors.textPrimary)
        }
    }
    
    // MARK: - Rejection Reason Section
    private func rejectionReasonSection(reason: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Rejection Reason")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            Text(reason)
                .font(.system(size: 16))
                .foregroundColor(.red)
                .lineSpacing(4)
        }
    }
    
    // MARK: - Status Section
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Status")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            if let status = viewModel.status {
                statusBadge(status: status)
            }
        }
    }
    
    private func statusBadge(status: ProposalStatus) -> some View {
        Text(status.displayName)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(colorForStatus(status).opacity(0.9))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(colorForStatus(status).opacity(0.15))
            .cornerRadius(12)
    }
    
    private func colorForStatus(_ status: ProposalStatus) -> Color {
        switch status {
        case .notViewed: return .orange
        case .viewed: return .blue
        case .accepted: return .green
        case .refused: return .red
        }
    }
    
    // MARK: - Bottom Actions Section (Recruiter only)
    @ViewBuilder
    private var bottomActionsSection: some View {
        if viewModel.canShowActions {
            acceptRefuseButtons
        } else if viewModel.showMessageButton {
            messageButton
        } else if viewModel.showRefusedIndicator {
            refusedIndicator
        }
    }
    
    private var acceptRefuseButtons: some View {
        HStack(spacing: 12) {
            Button {
                showRejectAlert = true
            } label: {
                Text("Refuse")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.red, lineWidth: 2)
                    )
            }
            .disabled(viewModel.isUpdatingStatus)
            
            Button {
                viewModel.acceptProposal()
            } label: {
                Text("Accept")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.Colors.primary)
                    .cornerRadius(16)
            }
            .disabled(viewModel.isUpdatingStatus)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            AppTheme.Colors.groupedBackground
                .shadow(color: AppTheme.Colors.cardShadow.opacity(0.3), radius: 6, x: 0, y: -2)
        )
    }
    
    private var messageButton: some View {
        Button {
            if viewModel.conversation != nil {
                showConversation = true
            } else {
                // Try to load/create conversation first
                viewModel.loadConversation()
                // Wait a bit then navigate
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if viewModel.conversation != nil {
                        showConversation = true
                    }
                }
            }
        } label: {
            Text("Message")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppTheme.Colors.primary)
                .cornerRadius(16)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            AppTheme.Colors.groupedBackground
                .shadow(color: AppTheme.Colors.cardShadow.opacity(0.3), radius: 6, x: 0, y: -2)
        )
    }
    
    private var refusedIndicator: some View {
        Text("Refused")
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(AppTheme.Colors.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppTheme.Colors.secondaryBackground)
            )
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                AppTheme.Colors.groupedBackground
                    .shadow(color: AppTheme.Colors.cardShadow.opacity(0.3), radius: 6, x: 0, y: -2)
            )
    }
}
