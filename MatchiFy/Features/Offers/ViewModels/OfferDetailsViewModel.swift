import Foundation
import SwiftUI
import Combine

@MainActor
class OfferDetailsViewModel: ObservableObject {
    @Published var offer: OfferModel
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var navigateToChat = false
    @Published var createdConversation: ConversationModel? // Store full model
    @Published var showReviewSheet = false
    
    var isRecruiter: Bool {
        AuthManager.shared.role == "recruiter"
    }
    
    init(offer: OfferModel) {
        self.offer = offer
    }
    
    func initiateChat() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let conversation = try await ConversationService.shared.createConversation(talentId: offer.talentId)
            createdConversation = conversation
            navigateToChat = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func submitReview(rating: Int, message: String) async {
        guard isRecruiter else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let updatedOffer = try await OfferService.shared.addReview(
                offerId: offer.offerId,
                rating: rating,
                message: message
            )
            self.offer = updatedOffer
            showReviewSheet = false
            successMessage = "Review submitted successfully"
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
