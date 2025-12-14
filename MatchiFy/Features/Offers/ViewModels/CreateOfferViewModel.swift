import SwiftUI
import PhotosUI
import Combine

@MainActor
class CreateOfferViewModel: ObservableObject {
    @Published var title = ""
    @Published var keywords: [String] = []
    @Published var keywordInput = ""
    @Published var price = ""
    @Published var description = ""
    
    // Optional fields
    @Published var showGalleryPicker = false
    @Published var showVideoPicker = false
    @Published var showCapabilities = false
    
    @Published var bannerImage: UIImage? {
        didSet {
            if let image = bannerImage {
                bannerImageData = image.jpegData(compressionQuality: 0.8)
                print("✅ Banner image data created: \(bannerImageData?.count ?? 0) bytes")
            } else {
                bannerImageData = nil
            }
        }
    }
    @Published var bannerImageData: Data?
    @Published var galleryImages: [UIImage] = []
    @Published var galleryImagesData: [Data] = []
    @Published var videoData: Data?
    @Published var capabilities: [String] = []
    @Published var capabilityInput = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var offerCreated = false
    
    let category: OfferCategory
    
    init(category: OfferCategory) {
        self.category = category
    }
    
    var isFormValid: Bool {
        !title.isEmpty &&
        !keywords.isEmpty &&
        !price.isEmpty &&
        Int(price) != nil &&
        !description.isEmpty &&
        bannerImage != nil
    }
    
    func addKeyword() {
        let trimmed = keywordInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !keywords.contains(trimmed) {
            keywords.append(trimmed)
            keywordInput = ""
        }
    }
    
    func removeKeyword(_ keyword: String) {
        keywords.removeAll { $0 == keyword }
    }
    
    func addCapability() {
        let trimmed = capabilityInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !capabilities.contains(trimmed) {
            capabilities.append(trimmed)
            capabilityInput = ""
        }
    }
    
    func removeCapability(_ capability: String) {
        capabilities.removeAll { $0 == capability }
    }
    
    func selectBannerImage(_ image: UIImage?) {
        bannerImage = image
        if let image = image {
            bannerImageData = image.jpegData(compressionQuality: 0.8)
        }
    }
    
    func addGalleryImage(_ image: UIImage) {
        guard galleryImages.count < 10 else { return }
        galleryImages.append(image)
        if let data = image.jpegData(compressionQuality: 0.8) {
            galleryImagesData.append(data)
        }
    }
    
    func removeGalleryImage(at index: Int) {
        guard index < galleryImages.count else { return }
        galleryImages.remove(at: index)
        galleryImagesData.remove(at: index)
    }
    
    func createOffer() async {
        print("📤 Starting createOffer()")
        
        guard isFormValid else {
            print("❌ Form validation failed")
            return
        }
        
        guard let bannerData = bannerImageData else {
            print("❌ Banner image data is nil")
            return
        }
        
        guard let priceValue = Int(price) else {
            print("❌ Price conversion failed")
            return
        }
        
        print("✅ All validations passed")
        print("📊 Offer details:")
        print("  Category: \(category.rawValue)")
        print("  Title: \(title)")
        print("  Keywords: \(keywords)")
        print("  Price: \(priceValue)")
        print("  Description length: \(description.count)")
        print("  Banner size: \(bannerData.count) bytes")
        print("  Gallery images: \(galleryImagesData.count)")
        print("  Capabilities: \(capabilities)")
        
        isLoading = true
        errorMessage = nil
        
        do {
            print("🌐 Calling API...")
            let offer = try await OfferService.shared.createOffer(
                category: category.rawValue,
                title: title,
                keywords: keywords,
                price: priceValue,
                description: description,
                capabilities: capabilities.isEmpty ? nil : capabilities,
                bannerImage: bannerData,
                galleryImages: galleryImagesData.isEmpty ? nil : galleryImagesData,
                introductionVideo: videoData
            )
            
            print("✅ API call successful!")
            print("📦 Created offer ID: \(offer.offerId)")
            
            isLoading = false
            offerCreated = true
            print("✅ offerCreated set to true - popup should close")
        } catch let error as ApiError {
            isLoading = false
            print("❌ API Error caught:")
            switch error {
            case .server(let message):
                print("  Server error: \(message)")
                errorMessage = message
            case .decoding:
                print("  Decoding error")
                errorMessage = "Failed to process server response"
            case .unknown:
                print("  Unknown API error")
                errorMessage = "An unknown error occurred"
            }
            showError = true
        } catch {
            isLoading = false
            print("❌ Unexpected error: \(error)")
            print("  Error type: \(type(of: error))")
            print("  Error description: \(error.localizedDescription)")
            errorMessage = "Failed to create offer: \(error.localizedDescription)"
            showError = true
        }
        
        print("🏁 createOffer() completed")
    }
}
