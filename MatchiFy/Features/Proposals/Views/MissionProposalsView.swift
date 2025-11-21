import SwiftUI
import Combine

struct MissionProposalsView: View {
    let missionId: String
    let missionTitle: String
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = MissionProposalsViewModel()
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
                                    isRecruiter: true
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
            .navigationTitle("Propositions - \(missionTitle)")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $selectedProposal) { proposal in
                ProposalDetailsView(
                    viewModel: ProposalDetailsViewModel(
                        proposalId: proposal.proposalId,
                        initialProposal: proposal
                    )
                )
            }
            .onAppear {
                viewModel.loadProposals(missionId: missionId)
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.Colors.textSecondary.opacity(0.4))
            Text("Aucune proposition")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            Text("Vous n'avez pas encore reçu de propositions pour cette mission.")
                .font(.system(size: 15))
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

@MainActor
final class MissionProposalsViewModel: ObservableObject {
    @Published private(set) var proposals: [ProposalModel] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    
    private let service = ProposalService.shared
    
    func loadProposals(missionId: String) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetched = try await service.getRecruiterProposals()
                // Filter by mission
                self.proposals = fetched.filter { $0.missionId == missionId }
                self.isLoading = false
            } catch {
                self.isLoading = false
                self.errorMessage = ErrorHandler.getErrorMessage(from: error, context: .general)
            }
        }
    }
}

