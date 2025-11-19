import SwiftUI

/// New Mission Card View matching the exact design from screenshots
struct MissionCardViewNew: View {
    let mission: MissionModel
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    
    var body: some View {
        Button(action: {
            // Tappable but no action yet
        }) {
            VStack(alignment: .leading, spacing: 0) {
                // MARK: - Card Content
                VStack(alignment: .leading, spacing: 12) {
                    // 1. Posted time (small, light-gray font)
                    HStack {
                        Text(mission.timePostedText)
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                        
                        Spacer()
                        
                        // 6. Favorite button (heart outlined, toggles to filled)
                        Button(action: onFavoriteToggle) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 18))
                                .foregroundColor(isFavorite ? .red : AppTheme.Colors.textSecondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // 2. Mission title (bold, medium-large font)
                    Text(mission.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // 3. Price (directly under title)
                    Text(mission.formattedBudget)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    // 4. Description (2 lines only, auto-truncate)
                    Text(mission.description)
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // 5. Skills (rounded pill-shaped tags, neutral gray background)
                    if !mission.skills.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(mission.skills, id: \.self) { skill in
                                    Text(skill)
                                        .font(.system(size: 13))
                                        .foregroundColor(AppTheme.Colors.textSecondary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(AppTheme.Colors.textSecondary.opacity(0.15))
                                        )
                                }
                            }
                            .padding(.horizontal, 1) // Prevent clipping
                        }
                    }
                }
                .padding(16)
            }
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(12)
            .shadow(color: AppTheme.Colors.cardShadow, radius: 4, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.Colors.border.opacity(0.3), lineWidth: 0.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

