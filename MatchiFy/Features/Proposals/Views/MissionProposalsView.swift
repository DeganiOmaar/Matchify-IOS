import SwiftUI
import Combine

struct MissionProposalsView: View {
    let missionId: String
    let missionTitle: String
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: MissionProposalsViewModel
    @State private var selectedProposal: ProposalModel? = nil
    @State private var sortMode: ProposalSortMode = .chronological
    
    init(missionId: String, missionTitle: String) {
        self.missionId = missionId
        self.missionTitle = missionTitle
        _viewModel = StateObject(wrappedValue: MissionProposalsViewModel(missionId: missionId))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Sort mode picker
                Picker("Sort Mode", selection: $sortMode) {
                    Text("All").tag(ProposalSortMode.chronological)
                    Text("AI Ranked").tag(ProposalSortMode.aiRanked)
                }
                .pickerStyle(.segmented)
                .padding()
                .onChange(of: sortMode) { _, newValue in
                    viewModel.loadProposals(sortMode: newValue)
                }
                
                // Content
                Group {
                    if viewModel.isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .progressViewStyle(.circular)
                            if sortMode == .aiRanked {
                                Text("AI is analyzing proposals...")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                            }
                        }
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
                                        isRecruiter: true,
                                        showAiScore: sortMode == .aiRanked
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
                viewModel.loadProposals(sortMode: sortMode)
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

enum ProposalSortMode {
    case chronological
    case aiRanked
}

@MainActor
final class MissionProposalsViewModel: ObservableObject {
    @Published private(set) var proposals: [ProposalModel] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    
    private let service = ProposalService.shared
    private let missionId: String
    
    init(missionId: String) {
        self.missionId = missionId
    }
    
    func loadProposals(sortMode: ProposalSortMode) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let useAiSort = sortMode == .aiRanked
                let response = try await service.getProposalsForMission(
                    missionId: missionId,
                    aiSort: useAiSort
                )
                self.proposals = response.proposals
                self.isLoading = false
            } catch {
                self.isLoading = false
                self.errorMessage = ErrorHandler.getErrorMessage(from: error, context: .general)
            }
        }
    }
}
