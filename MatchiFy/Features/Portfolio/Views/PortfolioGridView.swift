import SwiftUI

struct PortfolioGridView: View {
    let projects: [ProjectModel]
    let onProjectTap: (ProjectModel) -> Void
    let showAddButton: Bool
    let onAddProject: (() -> Void)?
    
    @State private var currentPage: Int = 1
    
    private let itemsPerPage = 4
    
    private var totalPages: Int {
        max(1, Int(ceil(Double(projects.count) / Double(itemsPerPage))))
    }
    
    private var currentPageProjects: [ProjectModel] {
        let startIndex = (currentPage - 1) * itemsPerPage
        let endIndex = min(startIndex + itemsPerPage, projects.count)
        guard startIndex < projects.count else { return [] }
        return Array(projects[startIndex..<endIndex])
    }
    
    private var canGoBack: Bool {
        currentPage > 1
    }
    
    private var canGoNext: Bool {
        currentPage < totalPages
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // MARK: - Header
            HStack {
                Text("Projects")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
                
                if showAddButton, let onAddProject = onAddProject {
                    Button {
                        onAddProject()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                }
            }
            
            // MARK: - Projects Grid
            if projects.isEmpty {
                emptyStateView
            } else {
                VStack(spacing: 16) {
                    // 2x2 Grid
                    // Calculate item width: screen width - external padding (40) - internal padding (40) - grid spacing (12)
                    let itemWidth = (UIScreen.main.bounds.width - 40 - 40 - 12) / 2
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 16) {
                        ForEach(currentPageProjects, id: \.projectId) { project in
                            ProjectGridItem(
                                project: project,
                                itemWidth: itemWidth
                            ) {
                                onProjectTap(project)
                            }
                        }
                    }
                    
                    // MARK: - Pagination Controls
                    if totalPages > 1 {
                        paginationControls
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
            
            if showAddButton, let onAddProject = onAddProject {
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
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    // MARK: - Pagination Controls
    private var paginationControls: some View {
        HStack {
            // Back Button
            Button {
                if canGoBack {
                    withAnimation {
                        currentPage -= 1
                    }
                }
            } label: {
                Text("Back")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(canGoBack ? AppTheme.Colors.primary : AppTheme.Colors.textSecondary.opacity(0.5))
            }
            .disabled(!canGoBack)
            
            Spacer()
            
            // Page Indicator
            Text("\(currentPage)/\(totalPages)")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Spacer()
            
            // Next Button
            Button {
                if canGoNext {
                    withAnimation {
                        currentPage += 1
                    }
                }
            } label: {
                Text("Next")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(canGoNext ? AppTheme.Colors.primary : AppTheme.Colors.textSecondary.opacity(0.5))
            }
            .disabled(!canGoNext)
        }
        .padding(.top, 8)
    }
}

// MARK: - Project Grid Item
struct ProjectGridItem: View {
    let project: ProjectModel
    let itemWidth: CGFloat
    let onTap: () -> Void
    
    private var imageHeight: CGFloat {
        itemWidth * 0.75 // 4:3 aspect ratio for grid items
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // MARK: - Project Image
                Group {
                    if let firstMedia = project.firstMediaItem {
                        MediaThumbnailView(
                            mediaItem: firstMedia,
                            size: CGSize(width: itemWidth, height: imageHeight)
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
                            .frame(width: itemWidth, height: imageHeight)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white.opacity(0.7))
                            )
                    }
                }
                .cornerRadius(12)
                .clipped()
                
                // MARK: - Project Title (Blue)
                Text(project.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(width: itemWidth, alignment: .leading)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

