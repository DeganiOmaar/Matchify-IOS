import SwiftUI
import AVKit
import PDFKit

struct ProjectDetailsView: View {
    let project: ProjectModel
    @State private var showEditProject = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // MARK: - Media Gallery
                if !project.media.isEmpty {
                    mediaSection
                }
                
                // MARK: - Project Info
                VStack(alignment: .leading, spacing: 20) {
                    // Title
                    Text(project.title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    // Role
                    if let role = project.role, !role.isEmpty {
                        Text(role)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                    
                    // Description (full text, no truncation)
                    if let description = project.description, !description.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                            
                            Text(description)
                                .font(.system(size: 15))
                                .foregroundColor(AppTheme.Colors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    
                    // Skills
                    if !project.skills.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Skills")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                            
                            FlowLayout(spacing: 8) {
                                ForEach(project.skills, id: \.self) { skill in
                                    Text(skill)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(AppTheme.Colors.primary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(AppTheme.Colors.primary.opacity(0.1))
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                    
                    // Project Link
                    if let projectLink = project.projectLink, !projectLink.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Project Link")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                            
                            Link(destination: URL(string: projectLink)!) {
                                HStack {
                                    Text(projectLink)
                                        .font(.system(size: 15))
                                        .foregroundColor(AppTheme.Colors.primary)
                                        .lineLimit(1)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.up.right.square")
                                        .foregroundColor(AppTheme.Colors.primary)
                                }
                                .padding()
                                .background(AppTheme.Colors.primary.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 20)
        }
        .navigationTitle("Project Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showEditProject = true
                } label: {
                    Text("Edit")
                        .foregroundColor(AppTheme.Colors.primary)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
        }
        .navigationDestination(isPresented: $showEditProject) {
            AddEditProjectView(project: project)
        }
    }
    
    // MARK: - Media Section
    private var mediaSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Media")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppTheme.Colors.textPrimary)
                .padding(.horizontal, 20)
            
            // Images
            if !project.images.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(project.images) { mediaItem in
                            if let url = mediaItem.mediaURL {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    case .failure, .empty:
                                        Rectangle()
                                            .fill(AppTheme.Colors.textSecondary.opacity(0.2))
                                    @unknown default:
                                        Rectangle()
                                            .fill(AppTheme.Colors.textSecondary.opacity(0.2))
                                    }
                                }
                                .frame(width: 300, height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            
            // Videos
            if !project.videos.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(project.videos) { mediaItem in
                        if let url = mediaItem.mediaURL {
                            VideoPlayer(player: AVPlayer(url: url))
                                .frame(height: 250)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .padding(.horizontal, 20)
                        }
                    }
                }
            }
            
            // PDFs
            if !project.pdfs.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(project.pdfs) { mediaItem in
                        if let url = mediaItem.mediaURL {
                            PDFCardView(
                                url: url,
                                title: mediaItem.title ?? "PDF Document"
                            )
                            .padding(.horizontal, 20)
                        }
                    }
                }
            }
            
            // External Links
            if !project.externalLinks.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(project.externalLinks) { mediaItem in
                        if let link = mediaItem.externalLink, let url = URL(string: link) {
                            Link(destination: url) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        if let title = mediaItem.title {
                                            Text(title)
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(AppTheme.Colors.textPrimary)
                                        }
                                        Text(link)
                                            .font(.system(size: 14))
                                            .foregroundColor(AppTheme.Colors.textSecondary)
                                            .lineLimit(1)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.up.right.square")
                                        .foregroundColor(AppTheme.Colors.primary)
                                }
                                .padding()
                                .background(AppTheme.Colors.secondaryBackground)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - PDF Card View
struct PDFCardView: View {
    let url: URL
    let title: String
    @State private var showPDFViewer = false
    
    var body: some View {
        Button {
            showPDFViewer = true
        } label: {
            HStack(spacing: 16) {
                // PDF Thumbnail
                PDFThumbnailView(url: url)
                    .frame(width: 80, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppTheme.Colors.border, lineWidth: 1)
                    )
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .lineLimit(2)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "doc.fill")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.Colors.primary)
                        
                        Text("PDF Document")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    
                    Text("Tap to view")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.Colors.primary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            .padding()
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(12)
            .shadow(color: AppTheme.Colors.cardShadow, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showPDFViewer) {
            PDFViewerView(url: url, title: title)
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}


