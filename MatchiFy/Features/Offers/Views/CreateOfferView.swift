import SwiftUI
import PhotosUI

struct CreateOfferView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CreateOfferViewModel
    @State private var showBannerPicker = false
    @State private var showGalleryPicker = false
    @State private var selectedGalleryImages: [UIImage] = []
    
    init(category: OfferCategory) {
        _viewModel = StateObject(wrappedValue: CreateOfferViewModel(category: category))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Category Badge
                        categoryBadge
                        
                        // Required Fields Section
                        requiredFieldsSection
                        
                        // Optional Details Section
                        optionalDetailsSection
                        
                        // Submit Button
                        submitButton
                    }
                    .padding(20)
                }
                
                if viewModel.isLoading {
                    LoadingOverlay()
                }
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("Create Offer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
            .onChange(of: viewModel.offerCreated) { created in
                if created {
                    dismiss()
                }
            }
        }
    }
    
    private var categoryBadge: some View {
        HStack {
            Image(systemName: viewModel.category.iconName)
            Text(viewModel.category.displayName)
                .font(.system(size: 15, weight: .semibold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(AppTheme.Colors.primary)
        .cornerRadius(20)
    }
    
    private var requiredFieldsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Required Information")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            // Title
            FormField(title: "Title", placeholder: "Enter service title") {
                TextField("", text: $viewModel.title)
                    .textFieldStyle(.plain)
            }
            
            // Keywords
            FormField(title: "Keywords", placeholder: "Add keywords") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        TextField("Add keyword", text: $viewModel.keywordInput)
                            .textFieldStyle(.plain)
                            .onSubmit {
                                viewModel.addKeyword()
                            }
                        
                        Button {
                            viewModel.addKeyword()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(AppTheme.Colors.primary)
                        }
                    }
                    
                    if !viewModel.keywords.isEmpty {
                        FlowLayout(spacing: 8) {
                            ForEach(viewModel.keywords, id: \.self) { keyword in
                                KeywordChip(text: keyword) {
                                    viewModel.removeKeyword(keyword)
                                }
                            }
                        }
                    }
                }
            }
            
            // Price
            FormField(title: "Price (€)", placeholder: "Enter price") {
                TextField("", text: $viewModel.price)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.plain)
            }
            
            // Description
            FormField(title: "Description", placeholder: "Describe your service") {
                TextEditor(text: $viewModel.description)
                    .frame(minHeight: 100)
                    .scrollContentBackground(.hidden)
            }
            
            // Banner Image
            FormField(title: "Banner Image *", placeholder: "Upload banner") {
                Button {
                    showBannerPicker = true
                } label: {
                    if let image = viewModel.bannerImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 150)
                            .clipped()
                            .cornerRadius(8)
                    } else {
                        HStack {
                            Image(systemName: "photo")
                            Text("Select Banner Image")
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 150)
                        .background(AppTheme.Colors.groupedBackground)
                        .cornerRadius(8)
                    }
                }
            }
            .sheet(isPresented: $showBannerPicker) {
                ImagePicker(image: $viewModel.bannerImage)
            }
            .sheet(isPresented: $showGalleryPicker) {
                MultipleImagePicker(images: $selectedGalleryImages)
            }
            .onChange(of: selectedGalleryImages) { _, newImages in
                for image in newImages {
                    viewModel.addGalleryImage(image)
                }
                selectedGalleryImages.removeAll()
            }
        }
    }
    
    private var optionalDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Optional Details")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            // Gallery Images Toggle
            OptionalDetailToggle(
                title: "Additional Pictures",
                subtitle: "Add up to 10 images",
                icon: "photo.on.rectangle",
                isEnabled: $viewModel.showGalleryPicker
            )
            
            if viewModel.showGalleryPicker {
                gallerySection
            }
            
            // Video Toggle
            OptionalDetailToggle(
                title: "Introduction Video",
                subtitle: "Add a video presentation",
                icon: "video.fill",
                isEnabled: $viewModel.showVideoPicker
            )
            
            // Capabilities Toggle
            OptionalDetailToggle(
                title: "Capabilities List",
                subtitle: "List your specific skills",
                icon: "list.bullet",
                isEnabled: $viewModel.showCapabilities
            )
            
            if viewModel.showCapabilities {
                capabilitiesSection
            }
        }
    }
    
    private var gallerySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                showGalleryPicker = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Images (\(viewModel.galleryImages.count)/10)")
                }
                .foregroundColor(AppTheme.Colors.primary)
            }
            .disabled(viewModel.galleryImages.count >= 10)
            
            if !viewModel.galleryImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(viewModel.galleryImages.enumerated()), id: \.offset) { index, image in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipped()
                                    .cornerRadius(8)
                                
                                Button {
                                    viewModel.removeGalleryImage(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.white)
                                        .background(Circle().fill(Color.black.opacity(0.5)))
                                }
                                .padding(4)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(AppTheme.Colors.groupedBackground)
        .cornerRadius(12)
    }
    
    private var capabilitiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                TextField("Add capability", text: $viewModel.capabilityInput)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        viewModel.addCapability()
                    }
                
                Button {
                    viewModel.addCapability()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(AppTheme.Colors.primary)
                }
            }
            .padding()
            .background(AppTheme.Colors.groupedBackground)
            .cornerRadius(8)
            
            if !viewModel.capabilities.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(viewModel.capabilities.enumerated()), id: \.offset) { index, capability in
                        HStack {
                            Text("• \(capability)")
                                .foregroundColor(AppTheme.Colors.textPrimary)
                            
                            Spacer()
                            
                            Button {
                                viewModel.removeCapability(capability)
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
    
    private var submitButton: some View {
        Button {
            print("🔍 Form Validation Debug:")
            print("  Title: '\(viewModel.title)' - isEmpty: \(viewModel.title.isEmpty)")
            print("  Keywords: \(viewModel.keywords) - isEmpty: \(viewModel.keywords.isEmpty)")
            print("  Price: '\(viewModel.price)' - isEmpty: \(viewModel.price.isEmpty), isValid: \(Int(viewModel.price) != nil)")
            print("  Description: '\(viewModel.description)' - isEmpty: \(viewModel.description.isEmpty)")
            print("  Banner: \(viewModel.bannerImage != nil ? "✅ Set" : "❌ Missing")")
            print("  isFormValid: \(viewModel.isFormValid)")
            
            Task {
                await viewModel.createOffer()
            }
        } label: {
            Text("Post Offer")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(viewModel.isFormValid ? AppTheme.Colors.primary : AppTheme.Colors.border)
                .cornerRadius(12)
        }
        .disabled(!viewModel.isFormValid || viewModel.isLoading)
        .padding(.top, 8)
    }
}

// MARK: - Supporting Views

struct FormField<Content: View>: View {
    let title: String
    let placeholder: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            content
                .padding()
                .background(AppTheme.Colors.groupedBackground)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppTheme.Colors.border.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

struct KeywordChip: View {
    let text: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.system(size: 14))
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(AppTheme.Colors.primary.opacity(0.1))
        .foregroundColor(AppTheme.Colors.primary)
        .cornerRadius(16)
    }
}

struct OptionalDetailToggle: View {
    let title: String
    let subtitle: String
    let icon: String
    @Binding var isEnabled: Bool
    
    var body: some View {
        Button {
            withAnimation {
                isEnabled.toggle()
            }
        } label: {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.Colors.primary)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: isEnabled ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isEnabled ? AppTheme.Colors.primary : AppTheme.Colors.border)
            }
            .padding()
            .background(AppTheme.Colors.groupedBackground)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)
        }
    }
}
