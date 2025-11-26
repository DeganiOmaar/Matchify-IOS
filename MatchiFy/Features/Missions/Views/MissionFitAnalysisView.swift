import SwiftUI
import Combine

struct MissionFitAnalysisView: View {
    let missionId: String
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = MissionFitAnalysisViewModel()
    
    // Helper function to get score color
    private func scoreColor(for score: Int) -> Color {
        if score >= 80 {
            return Color(red: 0.2, green: 0.8, blue: 0.2) // Green
        } else if score >= 50 {
            return Color(red: 1.0, green: 0.6, blue: 0.0) // Orange
        } else {
            return Color(red: 1.0, green: 0.3, blue: 0.3) // Red
        }
    }
    
    // Score section view
    @ViewBuilder
    private func scoreSection(analysis: MissionFitResponse) -> some View {
        VStack(spacing: 12) {
            Text("Match Score")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            HStack(spacing: 12) {
                // Score indicator circle
                Circle()
                    .fill(scoreColor(for: analysis.score))
                    .frame(width: 16, height: 16)
                    .shadow(color: scoreColor(for: analysis.score).opacity(0.5), radius: 4, x: 0, y: 2)
                
                Text("\(analysis.score)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(scoreColor(for: analysis.score))
            }
            
            // Progress indicator
            ProgressBarView(score: analysis.score, color: scoreColor(for: analysis.score))
        }
    }
    
    var body: some View {
        ZStack {
            // Blurred background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .background(.ultraThinMaterial)
                .onTapGesture {
                    dismiss()
                }
            
            // Modal content
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Mission Fit Analysis")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                Divider()
                    .background(AppTheme.Colors.border)
                
                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        if viewModel.isLoading {
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.2)
                                Text("Analyzing mission fit...")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                        } else if let error = viewModel.errorMessage {
                            VStack(spacing: 16) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.orange)
                                Text(error)
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                            .padding(.horizontal, 20)
                        } else if let analysis = viewModel.analysis {
                            // Radar Chart
                            VStack(spacing: 16) {
                                RadarChartView(data: analysis.radar)
                                    .frame(height: 280)
                                    .padding(.horizontal, 20)
                                
                                // Match Score
                                scoreSection(analysis: analysis)
                                .padding(.top, 8)
                                
                                // Summary
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Analysis Summary")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(AppTheme.Colors.textPrimary)
                                    
                                    Text(analysis.shortSummary)
                                        .font(.system(size: 14))
                                        .foregroundColor(AppTheme.Colors.textSecondary)
                                        .lineSpacing(4)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                                .padding(.top, 8)
                            }
                            .padding(.vertical, 20)
                        }
                    }
                }
            }
            .background(AppTheme.Colors.background)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.3), radius: 30, x: 0, y: 15)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 20)
            .padding(.vertical, 60)
        }
        .onAppear {
            viewModel.analyzeMissionFit(missionId: missionId)
        }
    }
}

@MainActor
final class MissionFitAnalysisViewModel: ObservableObject {
    @Published var analysis: MissionFitResponse?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let service = MissionFitService.shared
    
    func analyzeMissionFit(missionId: String) {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let result = try await service.analyzeMissionFit(missionId: missionId)
                await MainActor.run {
                    self.analysis = result
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = ErrorHandler.getErrorMessage(from: error, context: .general)
                }
            }
        }
    }
}

// Progress bar component
struct ProgressBarView: View {
    let score: Int
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background bar
                RoundedRectangle(cornerRadius: 4)
                    .fill(AppTheme.Colors.secondaryBackground)
                    .frame(height: 8)
                
                // Progress bar
                RoundedRectangle(cornerRadius: 4)
                    .fill(color)
                    .frame(
                        width: geometry.size.width * CGFloat(score) / 100,
                        height: 8
                    )
            }
        }
        .frame(height: 8)
        .padding(.horizontal, 20)
    }
}

#Preview {
    MissionFitAnalysisView(missionId: "preview")
}

