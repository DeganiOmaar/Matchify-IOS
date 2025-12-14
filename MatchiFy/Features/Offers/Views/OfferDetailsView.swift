import SwiftUI
import AVKit

struct OfferDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: OfferDetailsViewModel
    
    init(offer: OfferModel) {
        _viewModel = StateObject(wrappedValue: OfferDetailsViewModel(offer: offer))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Banner Image
                    bannerImage
                    
                    // Title and Price
                    titleSection
                    
                    Divider()
                    
                    // Contact & Actions Section (New)
                    if viewModel.isRecruiter {
                        actionsSection
                        Divider()
                    }
                    
                    // Category
                    categorySection
                    
                    // Keywords
                    keywordsSection
                    
                    Divider()
                    
                    // Description
                    descriptionSection
                    
                    // Introduction Video
                    if viewModel.offer.hasVideo {
                        Divider()
                        videoSection
                    }
                    
                    // Gallery
                    if !viewModel.offer.gallery.isEmpty {
                        Divider()
                        gallerySection
                    }
                    
                    // Capabilities
                    if !viewModel.offer.capabilitiesList.isEmpty {
                        Divider()
                        capabilitiesSection
                    }
                    
                    Divider()
                    
                    // Reviews Section (New)
                    reviewsSection
                }
                .padding(20)
            }
            .background(Color.black)
            .navigationTitle("Offer Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $viewModel.showReviewSheet) {
                AddReviewSheet(viewModel: viewModel)
            }
            .navigationDestination(isPresented: $viewModel.navigateToChat) {
                if let conversation = viewModel.createdConversation {
                    ConversationView(viewModel: ConversationViewModel(
                        conversationId: conversation.conversationId,
                        initialConversation: conversation
                    ))
                }
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .alert("Success", isPresented: Binding(
                get: { viewModel.successMessage != nil },
                set: { if !$0 { viewModel.successMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.successMessage ?? "")
            }
            .overlay(
                Group {
                    if viewModel.isLoading {
                        LoadingOverlay()
                    }
                }
            )
        }
    }
    
    private var actionsSection: some View {
        HStack(spacing: 12) {
            Button(action: {
                Task { await viewModel.initiateChat() }
            }) {
                Label("Contact Talent", systemImage: "message.fill")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.Colors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Button(action: {
                viewModel.showReviewSheet = true
            }) {
                Label("Rate Offer", systemImage: "star.fill")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
    
    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Reviews (\(viewModel.offer.reviewsList.count))")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            if viewModel.offer.reviewsList.isEmpty {
                Text("No reviews yet.")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            } else {
                ForEach(viewModel.offer.reviewsList) { review in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(review.recruiterName)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(AppTheme.Colors.textPrimary)
                            
                            Spacer()
                            
                            HStack(spacing: 2) {
                                ForEach(1...5, id: \.self) { star in
                                    Image(systemName: star <= review.rating ? "star.fill" : "star")
                                        .font(.system(size: 12))
                                        .foregroundColor(star <= review.rating ? .yellow : .gray)
                                }
                            }
                        }
                        
                        Text(review.message)
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    .padding()
                    .background(AppTheme.Colors.cardBackground)
                    .cornerRadius(12)
                }
            }
        }
    }
    
    // ... existing subviews using viewModel.offer instead of offer ...
    
    private var bannerImage: some View {
        AsyncImage(url: URL(string: "\(Endpoints.baseURL)/\(viewModel.offer.bannerImage)")) { phase in
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
            Text(viewModel.offer.title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text(viewModel.offer.formattedPrice)
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
                Image(systemName: OfferCategory(rawValue: viewModel.offer.category)?.iconName ?? "tag")
                Text(viewModel.offer.category)
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
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], alignment: .leading, spacing: 8) {
                ForEach(viewModel.offer.keywords, id: \.self) { keyword in
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
            
            Text(viewModel.offer.description)
                .font(.system(size: 16))
                .foregroundColor(AppTheme.Colors.textPrimary)
        }
    }
    
    private var videoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Introduction Video")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            if let videoPath = viewModel.offer.introductionVideo,
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
                    ForEach(viewModel.offer.gallery, id: \.self) { imagePath in
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
                ForEach(viewModel.offer.capabilitiesList, id: \.self) { capability in
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

// Helper Sheet for adding reviews
struct AddReviewSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: OfferDetailsViewModel
    @State private var rating = 5
    @State private var message = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Rating") {
                    HStack {
                        Spacer()
                        HStack(spacing: 8) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= rating ? "star.fill" : "star")
                                    .font(.system(size: 24))
                                    .foregroundColor(star <= rating ? .yellow : .gray)
                                    .onTapGesture {
                                        rating = star
                                    }
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                }
                
                Section("Review") {
                    TextEditor(text: $message)
                        .frame(height: 100)
                        .overlay(
                            Group {
                                if message.isEmpty {
                                    Text("Write your review here...")
                                        .foregroundColor(.gray)
                                        .padding(.top, 8)
                                        .padding(.leading, 5)
                                }
                            },
                            alignment: .topLeading
                        )
                }
            }
            .navigationTitle("Rate Offer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        Task {
                            await viewModel.submitReview(rating: rating, message: message)
                        }
                    }
                    .disabled(message.isEmpty)
                }
            }
        }
    }
}
