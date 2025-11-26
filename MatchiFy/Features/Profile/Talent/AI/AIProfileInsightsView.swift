import SwiftUI

struct AIProfileInsightsView: View {
    @StateObject private var viewModel = AIProfileInsightsViewModel()
    @State private var showError = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.primary)
                
                Text("AI Profile Insights")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
            }
            
            Text("Obtenez des recommandations personnalisées pour améliorer votre profil")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            // Content
            if viewModel.isLoading {
                loadingView
            } else if let analysis = viewModel.analysis {
                analysisContent(analysis: analysis)
            } else {
                emptyStateView
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(20)
        .shadow(color: AppTheme.Colors.cardShadow, radius: 8, x: 0, y: 3)
        .alert("Erreur", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            if let error = errorMessage {
                Text(error)
            }
        }
        .onAppear {
            // Load latest analysis when view appears
            viewModel.loadLatestAnalysis()
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.Colors.primary.opacity(0.6))
            
            Text("Aucune analyse disponible")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text("Analysez votre profil pour obtenir des recommandations personnalisées")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                viewModel.analyzeProfile { error in
                    errorMessage = error
                    showError = true
                }
            }) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "sparkles")
                            .font(.system(size: 16, weight: .medium))
                    }
                    
                    Text("Analyser mon profil")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppTheme.Colors.primary)
                .cornerRadius(12)
            }
            .disabled(viewModel.isLoading)
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Loading State
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.primary))
                .scaleEffect(1.2)
            
            Text("Analyse en cours...")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - Analysis Content
    private func analysisContent(analysis: ProfileAnalysisResponse) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Score Indicator
            scoreIndicator(score: analysis.profileScore)
            
            Divider()
                .background(AppTheme.Colors.separator)
            
            // Summary
            VStack(alignment: .leading, spacing: 8) {
                Text("Résumé")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Text(analysis.summary)
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Divider()
                .background(AppTheme.Colors.separator)
            
            // Key Strengths
            if !analysis.keyStrengths.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Points Forts")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(analysis.keyStrengths, id: \.self) { strength in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                    .foregroundColor(AppTheme.Colors.primary)
                                Text(strength)
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
            }
            
            Divider()
                .background(AppTheme.Colors.separator)
            
            // Areas to Improve
            if !analysis.areasToImprove.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.orange)
                        Text("Axes d'Amélioration")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(analysis.areasToImprove, id: \.self) { area in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                    .foregroundColor(AppTheme.Colors.primary)
                                Text(area)
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
            }
            
            Divider()
                .background(AppTheme.Colors.separator)
            
            // Recommended Tags
            if !analysis.recommendedTags.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tags Recommandés")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(analysis.recommendedTags, id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(AppTheme.Colors.primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(AppTheme.Colors.primary.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                }
            }
            
            // Re-analyze Button
            Button(action: {
                viewModel.analyzeProfile { error in
                    errorMessage = error
                    showError = true
                }
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .medium))
                    Text("Analyser à nouveau")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(AppTheme.Colors.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppTheme.Colors.primary.opacity(0.1))
                .cornerRadius(12)
            }
            .disabled(viewModel.isLoading)
            
            // Analysis Date
            if let analyzedDate = analysis.analyzedDate {
                Text("Analysé le \(formatDate(analyzedDate))")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.Colors.textSecondary.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
    
    // MARK: - Score Indicator
    private func scoreIndicator(score: Int) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("Score du Profil")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
                
                Text("\(score)/100")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(scoreColor(score))
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppTheme.Colors.secondaryBackground)
                        .frame(height: 12)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 8)
                        .fill(scoreColor(score))
                        .frame(width: geometry.size.width * CGFloat(score) / 100, height: 12)
                }
            }
            .frame(height: 12)
        }
    }
    
    // MARK: - Helpers
    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 0..<40:
            return .red
        case 40..<70:
            return .orange
        case 70..<85:
            return .blue
        default:
            return .green
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale(identifier: "fr_FR")
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        return displayFormatter.string(from: date)
    }
}


