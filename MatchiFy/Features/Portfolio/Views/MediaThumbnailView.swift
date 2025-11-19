import SwiftUI
import AVKit

/// Thumbnail view for portfolio list items
/// Displays placeholders/thumbnails instead of full media
struct MediaThumbnailView: View {
    let mediaItem: MediaItemModel
    let size: CGSize
    
    init(mediaItem: MediaItemModel, size: CGSize = CGSize(width: 300, height: 200)) {
        self.mediaItem = mediaItem
        self.size = size
    }
    
    var body: some View {
        Group {
            if mediaItem.isImage {
                imageThumbnail
            } else if mediaItem.isVideo {
                videoThumbnail
            } else if mediaItem.isPdf {
                pdfThumbnail
            } else {
                defaultThumbnail
            }
        }
        .frame(width: size.width, height: size.height)
        .contentShape(Rectangle())
        .clipped()
    }
    
    // MARK: - Image Thumbnail
    private var imageThumbnail: some View {
        Group {
            if let url = mediaItem.mediaURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .aspectRatio(16/9, contentMode: .fill)
                    case .failure, .empty:
                        defaultThumbnail
                    @unknown default:
                        defaultThumbnail
                    }
                }
            } else {
                defaultThumbnail
            }
        }
    }
    
    // MARK: - Video Thumbnail
    private var videoThumbnail: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    AppTheme.Colors.primary.opacity(0.7),
                    AppTheme.Colors.primary.opacity(0.5)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Try to load video thumbnail if URL exists
            if let url = mediaItem.mediaURL {
                VideoThumbnailGenerator(url: url)
                    .aspectRatio(16/9, contentMode: .fill)
            }
            
            // Play button overlay - perfectly centered
            Image(systemName: "play.circle.fill")
                .font(.system(size: 56))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.4), radius: 6, x: 0, y: 3)
        }
    }
    
    // MARK: - PDF Thumbnail
    private var pdfThumbnail: some View {
        ZStack {
            // Background
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            AppTheme.Colors.textSecondary.opacity(0.2),
                            AppTheme.Colors.textSecondary.opacity(0.15)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .aspectRatio(16/9, contentMode: .fill)
            
            VStack(spacing: 12) {
                Image(systemName: "doc.fill")
                    .font(.system(size: 50))
                    .foregroundColor(AppTheme.Colors.primary)
                
                Text("PDF Document")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                if let title = mediaItem.title, !title.isEmpty {
                    Text(title)
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .lineLimit(1)
                        .padding(.horizontal, 12)
                }
            }
        }
    }
    
    // MARK: - Default Thumbnail
    private var defaultThumbnail: some View {
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
            .aspectRatio(16/9, contentMode: .fill)
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 40))
                    .foregroundColor(.white.opacity(0.7))
            )
    }
}

// MARK: - Video Thumbnail Generator
struct VideoThumbnailGenerator: View {
    let url: URL
    @State private var thumbnail: UIImage? = nil
    
    var body: some View {
        Group {
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
                    .aspectRatio(16/9, contentMode: .fill)
            } else {
                Rectangle()
                    .fill(AppTheme.Colors.textSecondary.opacity(0.2))
                    .aspectRatio(16/9, contentMode: .fill)
            }
        }
        .onAppear {
            generateThumbnail()
        }
    }
    
    private func generateThumbnail() {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        let time = CMTime(seconds: 1, preferredTimescale: 60)
        
        Task {
            do {
                let cgImage = try await imageGenerator.image(at: time).image
                await MainActor.run {
                    self.thumbnail = UIImage(cgImage: cgImage)
                }
            } catch {
                // Failed to generate thumbnail, will use default background
                print("Failed to generate video thumbnail: \(error)")
            }
        }
    }
}

