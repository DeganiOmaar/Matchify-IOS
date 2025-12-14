import SwiftUI
import AVKit

struct OfferDetailsView: View {
    let offer: OfferModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Banner Image
                    bannerImage
                    
                    // Content
                    VStack(alignment: .leading, spacing: 20) {
                        // Title and Price
                        titleSection
                        
                        Divider()
                        
                        // Category
                        categorySection
                        
                        // Keywords
                        keywordsSection
                        
                        Divider()
                        
                        // Description
                        descriptionSection
                        
                        // Introduction Video
                        if offer.hasVideo {
                            Divider()
                            videoSection
                        }
                        
                        // Gallery
                        if !offer.gallery.isEmpty {
                            Divider()
                            gallerySection
                        }
                        
                        // Capabilities
                        if !offer.capabilitiesList.isEmpty {
                            Divider()
                            capabilitiesSection
                        }
                    }
                    .padding(20)
                }
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("Offer Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var bannerImage: some View {
        AsyncImage(url: URL(string: "\(Endpoints.baseURL)/\(offer.bannerImage)")) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure, .empty:
                Rectangle()
                    .fill(AppTheme.Colors.groupedBackground)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    )
            @unknown default:
                Rectangle()
                    .fill(AppTheme.Colors.groupedBackground)
            }
        }
        .frame(height: 250)
        .clipped()
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(offer.title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text(offer.formattedPrice)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppTheme.Colors.primary)
        }
    }
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Category")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            HStack {
                Image(systemName: OfferCategory(rawValue: offer.category)?.iconName ?? "tag")
                Text(offer.category)
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(AppTheme.Colors.textPrimary)
        }
    }
    
    private var keywordsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Keywords")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            // Simple wrapping layout using LazyVGrid
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], alignment: .leading, spacing: 8) {
                ForEach(offer.keywords, id: \.self) { keyword in
                    Text(keyword)
                        .font(.system(size: 14))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppTheme.Colors.primary.opacity(0.1))
                        .foregroundColor(AppTheme.Colors.primary)
                        .cornerRadius(16)
                }
            }
        }
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            Text(offer.description)
                .font(.system(size: 16))
                .foregroundColor(AppTheme.Colors.textPrimary)
        }
    }
    
    private var videoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Introduction Video")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            if let videoPath = offer.introductionVideo,
               let videoURL = URL(string: "\(Endpoints.baseURL)/\(videoPath)") {
                VideoPlayer(player: AVPlayer(url: videoURL))
                    .frame(height: 200)
                    .cornerRadius(12)
            }
        }
    }
    
    private var gallerySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Gallery")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(offer.gallery, id: \.self) { imagePath in
                        AsyncImage(url: URL(string: "\(Endpoints.baseURL)/\(imagePath)")) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            case .failure, .empty:
                                Rectangle()
                                    .fill(AppTheme.Colors.groupedBackground)
                            @unknown default:
                                Rectangle()
                                    .fill(AppTheme.Colors.groupedBackground)
                            }
                        }
                        .frame(width: 150, height: 150)
                        .clipped()
                        .cornerRadius(12)
                    }
                }
            }
        }
    }
    
    private var capabilitiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Capabilities")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(offer.capabilitiesList, id: \.self) { capability in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .foregroundColor(AppTheme.Colors.primary)
                        Text(capability)
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                    }
                }
            }
        }
    }
}
