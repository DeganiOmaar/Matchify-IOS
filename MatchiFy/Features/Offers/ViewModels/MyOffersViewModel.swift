import Foundation
import Combine

@MainActor
class MyOffersViewModel: ObservableObject {
    @Published var offers: [OfferModel] = []
    @Published var filteredOffers: [OfferModel] = []
    @Published var searchText: String = "" {
        didSet {
            applyFilters()
        }
    }
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage: String?
    
    private let offerService = OfferService()
    
    func loadMyOffers() {
        Task {
            isLoading = true
            do {
                offers = try await offerService.getAllOffers()
                filteredOffers = offers
                isLoading = false
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    func refresh() async {
        do {
            offers = try await offerService.getAllOffers()
            applyFilters()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    func deleteOffer(_ offer: OfferModel) {
        Task {
            do {
                try await offerService.deleteOffer(id: offer.offerId)
                // Remove from local array
                offers.removeAll { $0.offerId == offer.offerId }
                applyFilters()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    private func applyFilters() {
        if searchText.isEmpty {
            filteredOffers = offers
        } else {
            filteredOffers = offers.filter { offer in
                offer.title.localizedCaseInsensitiveContains(searchText) ||
                offer.description.localizedCaseInsensitiveContains(searchText) ||
                offer.keywords.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
    }
}
