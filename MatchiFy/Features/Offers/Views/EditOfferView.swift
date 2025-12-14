import SwiftUI
import PhotosUI

struct EditOfferView: View {
    let offer: OfferModel
    let onOfferUpdated: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var description: String
    @State private var price: String
    @State private var keywords: [String]
    @State private var keywordInput = ""
    @State private var capabilities: [String]
    @State private var capabilityInput = ""
    
    // Image/Video management
    @State private var bannerImage: UIImage?
    @State private var newBannerImage: UIImage?
    @State private var galleryImages: [UIImage] = []
    @State private var newGalleryImages: [UIImage] = []
    @State private var videoURL: String?
    @State private var newVideoData: Data?
    
    @State private var showBannerPicker = false
    @State private var showGalleryPicker = false
    @State private var showVideoPicker = false
    
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    init(offer: OfferModel, onOfferUpdated: @escaping () -> Void) {
        self.offer = offer
        self.onOfferUpdated = onOfferUpdated
        
        // Initialize state with existing offer data
        _title = State(initialValue: offer.title)
        _description = State(initialValue: offer.description)
        _price = State(initialValue: "\(offer.price)")
        _keywords = State(initialValue: offer.keywords)
        _capabilities = State(initialValue: offer.capabilities ?? [])
        _videoURL = State(initialValue: offer.introductionVideo)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Banner Image Section
                    bannerImageSection
                    
                    // Title
                    formField(title: "Title", text: $title, placeholder: "Title")
                    
                    // Description
                    descriptionField
                    
                    // Price
                    formField(title: "Price (€)", text: $price, placeholder: "Price")
                        .keyboardType(.decimalPad)
                    
                    // Keywords
                    keywordsSection
                    
                    // Capabilities
                    capabilitiesSection
                    
                    // Gallery Images (Optional)
                    gallerySection
                    
                    // Video (Optional)
                    videoSection
                    
                    // Update Button
                    updateButton
                }
                .padding(20)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("Edit Offer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showBannerPicker) {
                ImagePicker(image: $newBannerImage)
            }
            .sheet(isPresented: $showGalleryPicker) {
                MultipleImagePicker(images: $newGalleryImages)
            }
            .sheet(isPresented: $showVideoPicker) {
                VideoPicker(videoData: $newVideoData)
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Banner Image Section
    private var bannerImageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Banner Image")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            if let newImage = newBannerImage {
                Image(uiImage: newImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .cornerRadius(12)
                    .clipped()
            } else {
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
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                            )
                    @unknown default:
                        Rectangle()
                            .fill(AppTheme.Colors.groupedBackground)
                    }
                }
                .frame(height: 200)
                .cornerRadius(12)
                .clipped()
            }
            
            Button {
                showBannerPicker = true
            } label: {
                Text(newBannerImage != nil ? "Change Banner" : "Update Banner")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppTheme.Colors.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(AppTheme.Colors.primary.opacity(0.1))
                    .cornerRadius(10)
            }
        }
    }
    
    // MARK: - Gallery Section
    private var gallerySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Gallery Images (Optional)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            if !newGalleryImages.isEmpty || !(offer.galleryImages?.isEmpty ?? true) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // Existing gallery images
                        if newGalleryImages.isEmpty {
                            ForEach(offer.galleryImages ?? [], id: \.self) { imagePath in
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
                                .frame(width: 100, height: 100)
                                .cornerRadius(8)
                                .clipped()
                            }
                        }
                        
                        // New gallery images
                        ForEach(Array(newGalleryImages.enumerated()), id: \.offset) { index, image in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(8)
                                    .clipped()
                                
                                Button {
                                    newGalleryImages.remove(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .background(Color.white.clipShape(Circle()))
                                }
                                .padding(4)
                            }
                        }
                    }
                }
            }
            
            Button {
                showGalleryPicker = true
            } label: {
                HStack {
                    Image(systemName: "photo.on.rectangle.angled")
                    Text(newGalleryImages.isEmpty && (offer.galleryImages?.isEmpty ?? true) ? "Add Gallery Images" : "Update Gallery")
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppTheme.Colors.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(AppTheme.Colors.primary.opacity(0.1))
                .cornerRadius(10)
            }
        }
    }
    
    // MARK: - Video Section
    private var videoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Introduction Video (Optional)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            if newVideoData != nil {
                HStack {
                    Image(systemName: "video.fill")
                        .foregroundColor(AppTheme.Colors.primary)
                    Text("New video selected")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    Spacer()
                    Button {
                        newVideoData = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
                .padding(12)
                .background(AppTheme.Colors.cardBackground)
                .cornerRadius(10)
            } else if let videoURL = videoURL {
                HStack {
                    Image(systemName: "video.fill")
                        .foregroundColor(AppTheme.Colors.primary)
                    Text("Current video")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    Spacer()
                    Button {
                        self.videoURL = nil
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
                .padding(12)
                .background(AppTheme.Colors.cardBackground)
                .cornerRadius(10)
            }
            
            Button {
                showVideoPicker = true
            } label: {
                HStack {
                    Image(systemName: "video.badge.plus")
                    Text(newVideoData != nil || videoURL != nil ? "Change Video" : "Add Video")
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppTheme.Colors.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(AppTheme.Colors.primary.opacity(0.1))
                .cornerRadius(10)
            }
        }
    }
    
    // MARK: - Form Fields
    private func formField(title: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            TextField(placeholder, text: text)
                .textFieldStyle(.plain)
                .padding(12)
                .background(AppTheme.Colors.cardBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.Colors.border, lineWidth: 1)
                )
        }
    }
    
    private var descriptionField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            TextEditor(text: $description)
                .frame(height: 120)
                .padding(12)
                .background(AppTheme.Colors.cardBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.Colors.border, lineWidth: 1)
                )
        }
    }
    
    private var keywordsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Keywords")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            HStack {
                TextField("Add keyword", text: $keywordInput)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(AppTheme.Colors.cardBackground)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppTheme.Colors.border, lineWidth: 1)
                    )
                    .onSubmit {
                        addKeyword()
                    }
                
                Button(action: addKeyword) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(AppTheme.Colors.primary)
                }
            }
            
            if !keywords.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(keywords, id: \.self) { keyword in
                        KeywordChip(text: keyword) {
                            keywords.removeAll { $0 == keyword }
                        }
                    }
                }
            }
        }
    }
    
    private var capabilitiesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Capabilities (Optional)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            HStack {
                TextField("Add capability", text: $capabilityInput)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(AppTheme.Colors.cardBackground)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppTheme.Colors.border, lineWidth: 1)
                    )
                    .onSubmit {
                        addCapability()
                    }
                
                Button(action: addCapability) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(AppTheme.Colors.primary)
                }
            }
            
            if !capabilities.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(capabilities, id: \.self) { capability in
                        KeywordChip(text: capability) {
                            capabilities.removeAll { $0 == capability }
                        }
                    }
                }
            }
        }
    }
    
    private var updateButton: some View {
        Button {
            updateOffer()
        } label: {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            } else {
                Text("Update Offer")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
        }
        .background(isFormValid ? AppTheme.Colors.primary : AppTheme.Colors.textSecondary)
        .cornerRadius(12)
        .disabled(!isFormValid || isLoading)
    }
    
    // MARK: - Helper Methods
    private var isFormValid: Bool {
        !title.isEmpty && !description.isEmpty && !price.isEmpty && !keywords.isEmpty
    }
    
    private func addKeyword() {
        let trimmed = keywordInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !keywords.contains(trimmed) else { return }
        keywords.append(trimmed)
        keywordInput = ""
    }
    
    private func addCapability() {
        let trimmed = capabilityInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !capabilities.contains(trimmed) else { return }
        capabilities.append(trimmed)
        capabilityInput = ""
    }
    
    private func updateOffer() {
        isLoading = true
        
        Task {
            do {
                // For now, only update text fields
                // Image/video updates would require multipart form data
                try await OfferService().updateOffer(
                    id: offer.offerId,
                    title: title,
                    description: description,
                    price: Double(price) ?? 0,
                    keywords: keywords,
                    capabilities: capabilities.isEmpty ? nil : capabilities
                )
                
                await MainActor.run {
                    isLoading = false
                    onOfferUpdated()
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

// MARK: - Video Picker
struct VideoPicker: UIViewControllerRepresentable {
    @Binding var videoData: Data?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.mediaTypes = ["public.movie"]
        picker.videoQuality = .typeHigh
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: VideoPicker
        
        init(_ parent: VideoPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let videoURL = info[.mediaURL] as? URL {
                do {
                    parent.videoData = try Data(contentsOf: videoURL)
                } catch {
                    print("Error loading video: \\(error)")
                }
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
