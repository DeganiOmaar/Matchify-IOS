import SwiftUI
import AVKit

struct ProjectCardView: View {
    let project: ProjectModel
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var showMenu = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Media Preview
            if let mediaURL = project.mediaURL {
                ZStack {
                    if project.isVideo {
                        VideoPlayer(player: AVPlayer(url: mediaURL))
                            .frame(height: 200)
                            .clipped()
                    } else {
                        AsyncImage(url: mediaURL) { phase in
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
                        .frame(height: 200)
                        .clipped()
                    }
                    
                    // Play button overlay for videos
                    if project.isVideo {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
            } else {
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.6),
                                Color.purple.opacity(0.5)
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
                            .foregroundColor(.black)
                            .lineLimit(2)
                        
                        if let role = project.role, !role.isEmpty {
                            Text(role)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Spacer()
                    
                    // Three dots menu
                    Button {
                        showMenu = true
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(Color.gray.opacity(0.1))
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
                
                // Description
                if let description = project.description, !description.isEmpty {
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(3)
                }
                
                // Skills
                if !project.skills.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(project.skills, id: \.self) { skill in
                                Text(skill)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.blue.opacity(0.1))
                                    )
                            }
                        }
                    }
                }
            }
            .padding(20)
            .background(Color.white)
        }
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}

