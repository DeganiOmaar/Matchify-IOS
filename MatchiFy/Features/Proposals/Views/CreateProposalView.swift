import SwiftUI

struct CreateProposalView: View {
    @StateObject private var viewModel: CreateProposalViewModel
    @Environment(\.dismiss) private var dismiss
    let onSuccess: () -> Void
    
    init(
        viewModel: CreateProposalViewModel,
        onSuccess: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onSuccess = onSuccess
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    missionHeader
                    messageSection
                    proposalSection
                    optionalSection
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    sendButton
                }
                .padding(20)
            }
            .background(AppTheme.Colors.groupedBackground.ignoresSafeArea())
            .navigationTitle("Create Proposal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onChange(of: viewModel.submissionSuccess) { _, success in
                if success {
                    onSuccess()
                    dismiss()
                }
            }
        }
    }
    
    private var missionHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mission")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppTheme.Colors.textSecondary)
            Text(viewModel.missionTitle)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(16)
        .shadow(color: AppTheme.Colors.cardShadow, radius: 4, x: 0, y: 2)
    }
    
    private var messageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cover letter")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: $viewModel.message)
                    .frame(minHeight: 120)
                    .padding(12)
                    .background(AppTheme.Colors.cardBackground)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppTheme.Colors.border, lineWidth: 1)
                    )
                
                if viewModel.message.isEmpty {
                    Text("Introduce yourself, highlight experience, explain your approach...")
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .padding(20)
                        .allowsHitTesting(false)
                }
            }
        }
    }
    
    private var proposalSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Proposal")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
                
                Button {
                    viewModel.generateWithAI()
                } label: {
                    HStack(spacing: 4) {
                        if viewModel.isGeneratingAI {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "sparkles")
                                .font(.system(size: 14))
                        }
                        Text(viewModel.isGeneratingAI ? "Génération..." : "Générer avec IA")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(AppTheme.Colors.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppTheme.Colors.primary.opacity(0.1))
                    .cornerRadius(8)
                }
                .disabled(viewModel.isGeneratingAI)
            }
            
            Text("Généré par IA ou écrit par vous. C'est ce que le recruteur recevra comme proposition détaillée.")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: $viewModel.proposalContent)
                    .frame(minHeight: 200)
                    .padding(12)
                    .background(AppTheme.Colors.cardBackground)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                viewModel.proposalContent.trimmingCharacters(in: .whitespacesAndNewlines).count < 200 && !viewModel.proposalContent.isEmpty
                                ? Color.red.opacity(0.5)
                                : AppTheme.Colors.border,
                                lineWidth: 1
                            )
                    )
                
                if viewModel.proposalContent.isEmpty {
                    Text("Votre proposition détaillée pour cette mission...")
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .padding(20)
                        .allowsHitTesting(false)
                }
            }
            
            if !viewModel.proposalContent.isEmpty {
                let charCount = viewModel.proposalContent.trimmingCharacters(in: .whitespacesAndNewlines).count
                Text("\(charCount) / 200 caractères minimum")
                    .font(.system(size: 12))
                    .foregroundColor(charCount < 200 ? .red : AppTheme.Colors.textSecondary)
            }
        }
    }
    
    private var optionalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Optional details")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            VStack(spacing: 12) {
                TextField("Proposed budget (€)", text: Binding(
                    get: { viewModel.proposedBudget },
                    set: { newValue in
                        viewModel.proposedBudget = newValue.filter { $0.isNumber }
                    }
                ))
                .keyboardType(.numberPad)
                .padding()
                .background(AppTheme.Colors.cardBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.Colors.border, lineWidth: 1)
                )
                
                TextField("Estimated duration (e.g. 8 weeks)", text: $viewModel.estimatedDuration)
                    .padding()
                    .background(AppTheme.Colors.cardBackground)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppTheme.Colors.border, lineWidth: 1)
                    )
            }
        }
    }
    
    private var sendButton: some View {
        Button {
            viewModel.sendProposal()
        } label: {
            if viewModel.isSubmitting {
                ProgressView()
                    .progressViewStyle(.circular)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                Text("Send proposal")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.buttonText)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .disabled(!viewModel.isFormValid || viewModel.isSubmitting)
        .background(
            viewModel.isFormValid
            ? AppTheme.Colors.primary
            : AppTheme.Colors.primary.opacity(0.4)
        )
        .cornerRadius(16)
    }
}

