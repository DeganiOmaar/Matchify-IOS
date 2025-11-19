import SwiftUI
import AVKit
import PDFKit

struct ProjectCardView: View {
    let project: ProjectModel
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onTap: () -> Void
    
    @State private var showMenu = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // MARK: - Media Thumbnail (List View)
                if let firstMedia = project.firstMediaItem {
                    MediaThumbnailView(
                        mediaItem: firstMedia,
                        size: CGSize(width: UIScreen.main.bounds.width - 40, height: 200)
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
                        .frame(height: 200)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.white.opacity(0.7))
                        )
                }
                
                // MARK: - Content
                VStack(alignment: .leading, spacing: 16) {
                    // Header with title and menu
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(project.title)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppTheme.Colors.textPrimary)
                                .lineLimit(2)
                            
                            if let role = project.role, !role.isEmpty {
                                Text(role)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppTheme.Colors.primary)
                            }
                        }
                        
                        Spacer()
                        
                        // Three dots menu
                        Button {
                            showMenu = true
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                                .padding(8)
                                .background(
                                    Circle()
                                        .fill(AppTheme.Colors.textSecondary.opacity(0.1))
                                )
                        }
                        .confirmationDialog("Actions", isPresented: $showMenu) {
                            Button("Edit Project", role: .none) {
                                onEdit()
                            }
                            Button("Delete Project", role: .destructive) {
                                onDelete()
                            }
                            Button("Cancel", role: .cancel) {}
                        }
                    }
                    
                    // Description (limited to 3 lines in preview)
                    if let description = project.description, !description.isEmpty {
                        Text(description)
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .lineLimit(3)
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
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(AppTheme.Colors.primary.opacity(0.1))
                                        )
                                }
                            }
                        }
                    }
                }
                .padding(20)
                .background(AppTheme.Colors.cardBackground)
            }
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(20)
            .shadow(color: AppTheme.Colors.cardShadow, radius: 12, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(AppTheme.Colors.border, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
