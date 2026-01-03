import Foundation
import Combine
import StripePaymentSheet

@MainActor
class MissionPaymentViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var paymentSheet: PaymentSheet?
    @Published var isSuccess = false
    
    private let paymentService = PaymentService.shared
    
    @Published var currentPaymentIntentId: String?
    @Published var successMessage: String?
    
    func completeMission(missionId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await paymentService.completeMission(missionId: missionId)
            isLoading = false
            successMessage = "Mission marked as complete! The recruiter will be notified."
            
            // Notify to refresh mission list
            NotificationCenter.default.post(name: NSNotification.Name("MissionDidUpdate"), object: nil)
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
    
    func initiatePayment(missionId: String) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // 0. Biometric Authentication (Disabled for testing)
                /*
                do {
                    try await BiometricAuthManager.shared.authenticate()
                } catch BiometricError.canceled {
                    self.isLoading = false
                    return // Simply stop if user canceled
                } catch {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    return
                }
                */
                
                // 1. Create Payment Intent
                let response = try await paymentService.createPaymentIntent(missionId: missionId)
                self.currentPaymentIntentId = response.paymentIntentId
                
                // 2. Set Stripe Publishable Key
                if let publishableKey = response.publishableKey {
                    STPAPIClient.shared.publishableKey = publishableKey
                }
                
                // 3. Configure Stripe Sheet
                var configuration = PaymentSheet.Configuration()
                configuration.merchantDisplayName = "MatchiFy"
                
                if let customerId = response.customerId, let ephemeralKey = response.ephemeralKey {
                     configuration.customer = .init(id: customerId, ephemeralKeySecret: ephemeralKey)
                }

                // 3. Prepare Sheet
                self.paymentSheet = PaymentSheet(paymentIntentClientSecret: response.clientSecret, configuration: configuration)
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func onPaymentCompletion(result: PaymentSheetResult, missionId: String) {
        switch result {
        case .completed:
            confirmBackendPayment(missionId: missionId)
        case .canceled:
            self.errorMessage = "Payment canceled"
        case .failed(let error):
            self.errorMessage = error.localizedDescription
        }
    }
    
    private func confirmBackendPayment(missionId: String) {
        guard let paymentIntentId = currentPaymentIntentId else {
            self.errorMessage = "Missing payment info"
            return
        }
        
        isLoading = true
        Task {
            do {
                // 4. Confirm with Backend & Update Wallet
                _ = try await paymentService.confirmPayment(paymentIntentId: paymentIntentId, missionId: missionId)
                self.isSuccess = true
                self.isLoading = false
            } catch {
                self.errorMessage = "Payment confirmed but backend update failed: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
}

