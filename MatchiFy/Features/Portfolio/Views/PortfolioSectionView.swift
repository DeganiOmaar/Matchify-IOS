import SwiftUI

struct PortfolioSectionView: View {
    let projects: [ProjectModel]
    let onProjectTap: (ProjectModel) -> Void
    let onAddProject: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // MARK: - Header
            HStack {
                Text("Portfolio")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
                
                Button {
                    onAddProject()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(AppTheme.Colors.primary)
                }
            }
            
            // MARK: - Projects List
            if projects.isEmpty {
                emptyStateView
            } else {
                VStack(spacing: 16) {
                    ForEach(projects, id: \.projectId) { project in
                        CompactProjectCardView(project: project) {
                            onProjectTap(project)
                        }
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(20)
        .shadow(color: AppTheme.Colors.cardShadow, radius: 8, x: 0, y: 3)
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 40))
                .foregroundColor(AppTheme.Colors.textSecondary.opacity(0.5))
            
            Text("No Projects Yet")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            Text("Add your first project to showcase your work")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.Colors.textSecondary.opacity(0.7))
                .multilineTextAlignment(.center)
            
            Button {
                onAddProject()
            } label: {
                Text("Add Project")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppTheme.Colors.primary.opacity(0.1))
                    )
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
}

// MARK: - Compact Project Card
struct CompactProjectCardView: View {
    let project: ProjectModel
    let onTap: () -> Void
    
    // Calculate 16:9 aspect ratio height based on available width
    // PortfolioSectionView has 20px padding, so card width = screen - 40px
    private var cardWidth: CGFloat {
        UIScreen.main.bounds.width - 40
    }
    
    private var thumbnailHeight: CGFloat {
        (cardWidth * 9) / 16 // 16:9 aspect ratio
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // MARK: - Media Thumbnail (16:9 aspect ratio)
                Group {
                    if let firstMedia = project.firstMediaItem {
                        MediaThumbnailView(
                            mediaItem: firstMedia,
                            size: CGSize(width: cardWidth, height: thumbnailHeight)
                        )
                    } else {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        AppTheme.Colors.primary.opacity(0.6),
                                        AppTheme.Colors.primary.opacity(0.4)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: cardWidth, height: thumbnailHeight)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.7))
                            )
                    }
                }
                .cornerRadius(16, corners: [.topLeft, .topRight])
                
                // MARK: - Content
                VStack(alignment: .leading, spacing: 12) {
                    // Title
                    Text(project.title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Description (limited to 2-3 lines)
                    if let description = project.description, !description.isEmpty {
                        Text(description)
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    // Skills
                    if !project.skills.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(project.skills, id: \.self) { skill in
                                    Text(skill)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(AppTheme.Colors.primary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(AppTheme.Colors.primary.opacity(0.1))
                                        )
                                }
                            }
                            .padding(.horizontal, 1) // Prevent clipping
                        }
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.Colors.cardBackground)
            }
            .frame(maxWidth: .infinity)
            .background(AppTheme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: AppTheme.Colors.cardShadow, radius: 8, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppTheme.Colors.border.opacity(0.5), lineWidth: 0.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

