import SwiftUI
import AVKit

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
                        .foregroundColor(.black)
                    
                    // Role
                    if let role = project.role, !role.isEmpty {
                        Text(role)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.blue)
                    }
                    
                    // Description (full text, no truncation)
                    if let description = project.description, !description.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            Text(description)
                                .font(.system(size: 15))
                                .foregroundColor(.black)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    
                    // Skills
                    if !project.skills.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Skills")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            FlowLayout(spacing: 8) {
                                ForEach(project.skills, id: \.self) { skill in
                                    Text(skill)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.blue)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue.opacity(0.1))
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
                                .foregroundColor(.gray)
                            
                            Link(destination: URL(string: projectLink)!) {
                                HStack {
                                    Text(projectLink)
                                        .font(.system(size: 15))
                                        .foregroundColor(.blue)
                                        .lineLimit(1)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.up.right.square")
                                        .foregroundColor(.blue)
                                }
                                .padding()
                                .background(Color.blue.opacity(0.1))
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
                        .foregroundColor(.blue)
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
                                            .fill(Color.gray.opacity(0.2))
                                    @unknown default:
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
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
                            PDFViewer(url: url, title: mediaItem.title ?? "PDF Document")
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
                                                .foregroundColor(.black)
                                        }
                                        Text(link)
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                            .lineLimit(1)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.up.right.square")
                                        .foregroundColor(.blue)
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
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

// MARK: - PDF Viewer
struct PDFViewer: View {
    let url: URL
    let title: String
    @State private var showShareSheet = false
    
    var body: some View {
        Button {
            showShareSheet = true
        } label: {
            HStack {
                Image(systemName: "doc.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.red)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text("Tap to open")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [url])
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

