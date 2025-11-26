import SwiftUI

/// New Mission Card View matching the exact design from screenshots
struct MissionCardViewNew: View {
    enum Action {
        case favorite(isFavorite: () -> Bool, toggle: () -> Void)
        case ownerMenu(onEdit: () -> Void, onDelete: () -> Void, onViewProposals: (() -> Void)? = nil)
    }
    
    let mission: MissionModel
    let action: Action?
    let onTap: (() -> Void)?
    let matchScore: Int?
    let reasoning: String?
    let showAIMatchBadge: Bool
    
    init(
        mission: MissionModel,
        action: Action? = nil,
        onTap: (() -> Void)? = nil,
        matchScore: Int? = nil,
        reasoning: String? = nil,
        showAIMatchBadge: Bool = false
    ) {
        self.mission = mission
        self.action = action
        self.onTap = onTap
        self.matchScore = matchScore
        self.reasoning = reasoning
        self.showAIMatchBadge = showAIMatchBadge
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Card Content
            VStack(alignment: .leading, spacing: 12) {
                // 1. Posted time and AI Match badge (small, light-gray font)
                HStack {
                    HStack(spacing: 8) {
                        Text(mission.timePostedText)
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                        
                        if showAIMatchBadge {
                            HStack(spacing: 4) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 11))
                                    .foregroundColor(AppTheme.Colors.primary)
                                Text("AI Match")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(AppTheme.Colors.primary)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(AppTheme.Colors.primary.opacity(0.1))
                            )
                        }
                    }
                    
                    Spacer()
                    
                    actionView
                }
                
                // 2. Mission title (bold, medium-large font)
                Text(mission.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                // 3. Price and Match Score (directly under title)
                HStack(alignment: .center, spacing: 12) {
                    Text(mission.formattedBudget)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    if let matchScore = matchScore {
                        HStack(spacing: 4) {
                            Text("\(matchScore)%")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(AppTheme.Colors.primary)
                            Text("match")
                                .font(.system(size: 13))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                    }
                }
                
                // 4. Description (2 lines only, auto-truncate)
                Text(mission.description)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                // 4.5. Reasoning (if available, 1-2 lines)
                if let reasoning = reasoning, !reasoning.isEmpty {
                    Text(reasoning)
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.Colors.primary.opacity(0.8))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 4)
                }
                
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
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?()
        }
    }
    
    @ViewBuilder
    private var actionView: some View {
        if let action {
            switch action {
            case .favorite(let isFavorite, let toggle):
                Button(action: toggle) {
                    Image(systemName: isFavorite() ? "heart.fill" : "heart")
                        .font(.system(size: 18))
                        .foregroundColor(isFavorite() ? .red : AppTheme.Colors.textSecondary)
                }
                .buttonStyle(PlainButtonStyle())
                
            case .ownerMenu(let onEdit, let onDelete, let onViewProposals):
                Menu {
                    if let onViewProposals = onViewProposals {
                        Button("Voir propositions", action: onViewProposals)
                    }
                    Button("Edit", action: onEdit)
                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        Text("Delete")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .rotationEffect(.degrees(90))
                        .padding(.horizontal, 4)
                }
                .menuIndicator(.hidden)
            }
        }
    }
}

