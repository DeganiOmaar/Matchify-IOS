import Foundation
import Combine

final class VerificationCodeViewModel: ObservableObject {
    @Published var code: String = "" {
        didSet {
            if code.count > 6 { code = String(code.prefix(6)) }
        }
    }
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var goNext: Bool = false
    
    var isButtonDisabled: Bool {
        code.count != 6 || isLoading
    }
    
    func verifyCode() {
        errorMessage = nil
        
        if code.count != 6 {
            errorMessage = "Le code doit contenir 6 chiffres."
            return
        }
        
        Task { @MainActor in
            isLoading = true
            
            do {
                let response = try await AuthService.shared.verifyResetCode(code: code)
                print("✔ Code Verified:", response.message)

                isLoading = false
                goNext = true

            } catch {
                isLoading = false
                errorMessage = ErrorHandler.getErrorMessage(from: error, context: .verifyCode)
            }
        }
    }
}
