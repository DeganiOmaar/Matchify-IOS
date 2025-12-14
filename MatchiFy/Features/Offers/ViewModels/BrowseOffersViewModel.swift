import SwiftUI
import Combine

@MainActor
class BrowseOffersViewModel: ObservableObject {
    @Published var offers: [OfferModel] = []
    @Published var filteredOffers: [OfferModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    @Published var searchText = ""
    @Published var selectedCategory: OfferCategory?
    
    init() {
        Task {
            await loadOffers()
        }
    }
    
    func loadOffers() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedOffers = try await OfferService.shared.getAllOffers(
                category: selectedCategory?.rawValue,
                search: searchText.isEmpty ? nil : searchText
            )
            offers = fetchedOffers
            filteredOffers = fetchedOffers
            isLoading = false
        } catch let error as ApiError {
            isLoading = false
            switch error {
            case .server(let message):
                errorMessage = message
            case .decoding:
                errorMessage = "Failed to process server response"
            case .unknown:
                errorMessage = "An unknown error occurred"
            }
            showError = true
        } catch {
            isLoading = false
            errorMessage = "Failed to load offers: \(error.localizedDescription)"
            showError = true
        }
    }
    
    func applyFilters() {
        Task {
            await loadOffers()
        }
    }
    
    func clearFilters() {
        searchText = ""
        selectedCategory = nil
        Task {
            await loadOffers()
        }
    }
    
    func refresh() async {
        await loadOffers()
    }
}
