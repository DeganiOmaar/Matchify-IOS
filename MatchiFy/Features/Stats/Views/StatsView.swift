import SwiftUI

struct StatsView: View {
    @StateObject private var viewModel = StatsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // MARK: - Section 1: Overview Block
                overviewSection
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 24)
                
                Divider()
                    .background(AppTheme.Colors.border.opacity(0.3))
                    .padding(.horizontal, 20)
                
                // MARK: - Section 2: Job Success Score Block
                jobSuccessScoreSection
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 24)
                
                Divider()
                    .background(AppTheme.Colors.border.opacity(0.3))
                    .padding(.horizontal, 20)
                
                // MARK: - Section 3: Proposals Section
                proposalsSection
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
            }
        }
        .background(AppTheme.Colors.groupedBackground)
        .navigationTitle("My stats")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Section 1: Overview Block
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title
            Text("My stats")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            // Description Section
            VStack(alignment: .leading, spacing: 8) {
                Text("View proposal history, earnings, profile analytics, and your Job Success Score.")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Text("Stats are not updated in real-time and may take up to 24 hours to reflect recent activity.")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            
            // Earnings Section
            VStack(alignment: .leading, spacing: 8) {
                Text("12-month earnings")
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                
                Text(viewModel.formattedEarnings)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }
            .padding(.top, 8)
        }
    }
    
    // MARK: - Section 2: Job Success Score Block
    private var jobSuccessScoreSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title Row with Info Icon
            HStack(alignment: .center, spacing: 8) {
                Text("Job Success Score")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Button {
                    // TODO: Show info popup later
                } label: {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.Colors.iconSecondary)
                }
                .buttonStyle(.plain)
                .frame(width: 20, height: 20)
                
                Spacer()
            }
            
            // Description Text
            Text("Leverage Job Success insights to help you learn how to earn or regain a score.")
                .font(.system(size: 15))
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            // Score Circle Section
            HStack(alignment: .center) {
                Spacer()
                
                VStack(spacing: 12) {
                    // Score Circle
                    ZStack {
                        Circle()
                            .stroke(AppTheme.Colors.border.opacity(0.3), lineWidth: 3)
                            .frame(width: 120, height: 120)
                        
                        Text(viewModel.jobSuccessScoreText)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    
                    // "No score" with info icon
                    HStack(spacing: 4) {
                        Text("No score")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                        
                        Image(systemName: "info.circle")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.Colors.iconSecondary)
                    }
                }
            }
            .padding(.top, 8)
        }
    }
    
    // MARK: - Section 3: Proposals Section
    private var proposalsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title Row with Dropdown
            HStack {
                Text("Proposals")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
                
                // Dropdown Selector
                Menu {
                    ForEach(StatsModel.Timeframe.allCases, id: \.self) { timeframe in
                        Button {
                            viewModel.selectedTimeframe = timeframe
                        } label: {
                            HStack {
                                Text(timeframe.rawValue)
                                if viewModel.selectedTimeframe == timeframe {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(viewModel.selectedTimeframe.rawValue)
                            .font(.system(size: 15))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.iconSecondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(AppTheme.Colors.inputBackground)
                    .cornerRadius(8)
                }
            }
            
            // Proposals Count
            Text(viewModel.proposalsSentText)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(AppTheme.Colors.textPrimary)
                .padding(.top, 4)
            
            // Graph and Stats Row
            HStack(alignment: .top, spacing: 24) {
                // Graph Placeholder
                graphPlaceholder
                
                // Stats List
                statsList
            }
            .padding(.top, 16)
            
            // "My proposals" Link
            HStack {
                Spacer()
                
                Text("My proposals")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.green)
                    .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Graph Placeholder
    private var graphPlaceholder: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Four vertical bars
            HStack(alignment: .bottom, spacing: 12) {
                // Bar 1 - Organic
                VStack(spacing: 4) {
                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppTheme.Colors.border.opacity(0.2))
                            .frame(width: 20, height: 80)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(organicColor)
                            .frame(width: 20, height: 40)
                    }
                }
                
                // Bar 2 - Organic
                VStack(spacing: 4) {
                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppTheme.Colors.border.opacity(0.2))
                            .frame(width: 20, height: 80)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(organicColor)
                            .frame(width: 20, height: 50)
                    }
                }
                
                // Bar 3 - Boosted
                VStack(spacing: 4) {
                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppTheme.Colors.border.opacity(0.2))
                            .frame(width: 20, height: 80)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(boostedColor)
                            .frame(width: 20, height: 30)
                    }
                }
                
                // Bar 4 - Boosted
                VStack(spacing: 4) {
                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppTheme.Colors.border.opacity(0.2))
                            .frame(width: 20, height: 80)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(boostedColor)
                            .frame(width: 20, height: 25)
                    }
                }
            }
            
            // Labels
            HStack(spacing: 20) {
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(organicColor)
                        .frame(width: 12, height: 12)
                    
                    Text("Organic")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(boostedColor)
                        .frame(width: 12, height: 12)
                    
                    Text("Boosted")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
            .padding(.top, 8)
        }
    }
    
    // MARK: - Color Helpers
    private var organicColor: Color {
        // Light turquoise - adapts to dark mode
        Color(red: 0.4, green: 0.8, blue: 0.8)
    }
    
    private var boostedColor: Color {
        // Deeper blue - adapts to dark mode
        AppTheme.Colors.primary
    }
    
    // MARK: - Stats List
    private var statsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(viewModel.stats.proposalsSent) proposals sent")
                .font(.system(size: 15))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text("\(viewModel.stats.proposalsViewed) were viewed")
                .font(.system(size: 15))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text("\(viewModel.stats.interviews) interviews")
                .font(.system(size: 15))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text("\(viewModel.stats.hires) hires")
                .font(.system(size: 15))
                .foregroundColor(AppTheme.Colors.textPrimary)
        }
    }
}

#Preview {
    NavigationStack {
        StatsView()
    }
}

