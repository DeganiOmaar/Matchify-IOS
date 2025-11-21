import SwiftUI
import Combine

struct ContractReviewView: View {
    let contract: ContractModel
    let onSigned: () -> Void
    let onDeclined: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ContractReviewViewModel()
    @State private var showSignaturePad = false
    @State private var signatureImage: UIImage?
    @State private var hasSigned = false
    @State private var isSending = false
    @State private var showSuccessMessage = false
    @State private var loadedContract: ContractModel?
    
    // Use loaded contract if available, otherwise use initial contract
    private var currentContract: ContractModel {
        loadedContract ?? contract
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(currentContract.title)
                        .font(.title2)
                        .bold()
                    
                    Text(currentContract.content)
                        .font(.body)
                    
                    if let paymentDetails = currentContract.paymentDetails {
                        Text("Payment details: \(paymentDetails)")
                            .font(.subheadline)
                    }
                    
                    if let startDate = currentContract.startDate {
                        Text("Start date: \(formatDate(startDate))")
                            .font(.subheadline)
                    }
                    
                    if let endDate = currentContract.endDate {
                        Text("End date: \(formatDate(endDate))")
                            .font(.subheadline)
                    }
                    
                    // Show recruiter signature (always visible)
                    if !currentContract.recruiterSignature.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Signature du recruteur:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            if let recruiterSigImage = imageFromBase64(currentContract.recruiterSignature) {
                                Image(uiImage: recruiterSigImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 100)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            } else {
                                Text("Image de signature indisponible")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(height: 100)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    } else {
                        // Show warning if recruiter signature is missing
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("La signature du recruteur est manquante. Le contrat ne peut pas être signé.")
                                .font(.subheadline)
                                .foregroundColor(.orange)
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    // Show talent signature if signed
                    if let signature = signatureImage {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your signature:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Image(uiImage: signature)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                    } else if let talentSignature = currentContract.talentSignature, !talentSignature.isEmpty {
                        // Show existing talent signature if contract was already signed
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your signature:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            if let talentSigImage = imageFromBase64(talentSignature) {
                                Image(uiImage: talentSigImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 100)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    
                    // Success message
                    if showSuccessMessage {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Contract signed and sent to recruiter successfully!")
                                .font(.subheadline)
                                .foregroundColor(.green)
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    // Error message
                    if let errorMessage = viewModel.errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundColor(.red)
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    // Send button (only if signed but not sent yet)
                    if hasSigned && !showSuccessMessage {
                        let canSend = !currentContract.title.isEmpty &&
                                     !currentContract.content.isEmpty &&
                                     !currentContract.recruiterSignature.isEmpty &&
                                     signatureImage != nil
                        
                        Button {
                            sendSignedContract()
                        } label: {
                            HStack {
                                if isSending {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "paperplane.fill")
                                }
                                Text(isSending ? "Envoi..." : "Envoyer au recruteur")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(canSend ? AppTheme.Colors.primary : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(isSending || !canSend)
                    }
                }
                .padding()
            }
            .navigationTitle("Contract Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Decline") {
                        viewModel.declineContract(contractId: currentContract.contractId) {
                            onDeclined()
                            dismiss()
                        }
                    }
                    .foregroundColor(.red)
                    .disabled(hasSigned)
                }
                ToolbarItem(placement: .confirmationAction) {
                    if !hasSigned {
                        Button("Sign") {
                            showSignaturePad = true
                        }
                    } else {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }
            }
            .sheet(isPresented: $showSignaturePad) {
                SignaturePadView(image: $signatureImage)
                    .onDisappear {
                        if signatureImage != nil {
                            hasSigned = true
                        }
                    }
            }
            .onAppear {
                // Reload contract from backend to ensure we have latest data including recruiter signature
                loadContract()
            }
        }
    }
    
    private func loadContract() {
        Task {
            do {
                let contract = try await ContractService.shared.getContract(id: currentContract.contractId)
                await MainActor.run {
                    loadedContract = contract
                }
            } catch {
                // If loading fails, use the initial contract
                // Error is not critical - we can still show the contract
                print("Failed to reload contract: \(error.localizedDescription)")
            }
        }
    }
    
    private func imageFromBase64(_ base64String: String) -> UIImage? {
        // Remove data URL prefix if present
        let base64 = base64String.replacingOccurrences(
            of: "data:image/[^;]+;base64,",
            with: "",
            options: .regularExpression
        )
        
        guard let imageData = Data(base64Encoded: base64) else {
            return nil
        }
        return UIImage(data: imageData)
    }
    
    private func sendSignedContract() {
        // Clear any previous error messages
        viewModel.errorMessage = nil
        
        // Validate all required fields according to backend rules
        
        // 1. Validate talent signature (required in request)
        guard let signature = signatureImage else {
            viewModel.errorMessage = "Veuillez fournir votre signature"
            return
        }
        
        // 2. Validate contract has all required fields (title, content, recruiterSignature)
        // This is a UX check - backend will also validate, but we check here to prevent unnecessary API calls
        var missingFields: [String] = []
        
        if currentContract.title.isEmpty || currentContract.title.trimmingCharacters(in: .whitespaces).isEmpty {
            missingFields.append("title")
        }
        
        if currentContract.content.isEmpty || currentContract.content.trimmingCharacters(in: .whitespaces).isEmpty {
            missingFields.append("content")
        }
        
        if currentContract.recruiterSignature.isEmpty || currentContract.recruiterSignature.trimmingCharacters(in: .whitespaces).isEmpty {
            missingFields.append("recruiterSignature")
        }
        
        if !missingFields.isEmpty {
            let fieldNames = missingFields.map { field in
                switch field {
                case "title": return "le titre"
                case "content": return "le contenu"
                case "recruiterSignature": return "la signature du recruteur"
                default: return field
                }
            }
            viewModel.errorMessage = "Le contrat est incomplet. Champs manquants: \(fieldNames.joined(separator: ", "))"
            return
        }
        
        // All validations passed - proceed with sending
        isSending = true
        viewModel.errorMessage = nil
        
        viewModel.signContract(
            contractId: currentContract.contractId,
            signature: signature
        ) { success in
            isSending = false
            
            if success {
                // Success - clear any error messages and show success
                viewModel.errorMessage = nil
                showSuccessMessage = true
                
                // Notify that contract was signed and messages should reload
                NotificationCenter.default.post(
                    name: NSNotification.Name("ContractSigned"),
                    object: currentContract.contractId
                )
                
                // Auto-dismiss after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    onSigned()
                    dismiss()
                }
            } else {
                // Error handling - only show error if backend explicitly returned one
                // Don't show generic "required fields" if backend saved successfully
                if let errorMsg = viewModel.errorMessage, !errorMsg.isEmpty {
                    // Error message is already set by the ViewModel
                    // Only show it if it's a real error from backend
                    print("⚠️ Contract signing error: \(errorMsg)")
                } else {
                    // No error message but success is false - this shouldn't happen
                    // But don't show a false error
                    print("⚠️ Contract signing returned false but no error message")
                }
            }
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = iso.date(from: dateString) {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "fr_FR")
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
        // Try with just date format
        iso.formatOptions = [.withFullDate]
        if let date = iso.date(from: dateString) {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "fr_FR")
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
        return dateString
    }
}

@MainActor
final class ContractReviewViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let service = ContractService.shared
    
    func signContract(
        contractId: String,
        signature: UIImage,
        completion: @escaping (Bool) -> Void
    ) {
        guard let signatureData = signature.pngData() else {
            errorMessage = "Échec du traitement de la signature"
            completion(false)
            return
        }
        let base64Signature = signatureData.base64EncodedString()
        
        isLoading = true
        errorMessage = nil
        
        let request = SignContractRequest(
            talentSignature: "data:image/png;base64,\(base64Signature)"
        )
        
        Task {
            do {
                // Call the service - if this succeeds (no exception), the contract was signed successfully
                // The backend returns status 200 with the updated contract
                let signedContract = try await service.signContract(id: contractId, request: request)
                
                // If we get here, the API call was successful (status 200) and decoding succeeded
                // This means the backend successfully saved the contract
                print("✅ Contract signed successfully. Status: \(signedContract.status.rawValue)")
                print("✅ Contract ID: \(signedContract.contractId)")
                
                await MainActor.run {
                    isLoading = false
                    errorMessage = nil  // Clear any previous errors - success!
                    completion(true)     // Success - backend saved everything correctly
                }
            } catch let error as ApiError {
                // Handle ApiError - this means the backend returned an error status (4xx or 5xx)
                await MainActor.run {
                    isLoading = false
                    
                    // Get the error message
                    let errorMsg = ErrorHandler.getErrorMessage(from: error, context: .general)
                    let lowerMsg = errorMsg.lowercased()
                    
                    // Only show error if backend explicitly returned a validation error
                    // Backend validation errors will have "missingFields" in the response
                    // which ApiClient converts to "Missing required fields: ..."
                    let isBackendValidationError = lowerMsg.contains("missing required fields") ||
                                                   lowerMsg.contains("contract validation failed")
                    
                    if isBackendValidationError {
                        // Real backend validation error - show it
                        errorMessage = errorMsg
                        completion(false)
                    } else {
                        // Other backend error (not validation) - show it
                        errorMessage = errorMsg
                        completion(false)
                    }
                }
            } catch {
                // Handle other errors (decoding, network, etc.)
                await MainActor.run {
                    isLoading = false
                    
                    // Check if it's a decoding error
                    if case ApiError.decoding = error {
                        // Decoding failed - this shouldn't happen if backend returns valid JSON
                        // But if it does, it might mean the response format changed
                        print("⚠️ Decoding error - response format may have changed")
                        errorMessage = "Erreur lors du traitement de la réponse du serveur."
                    } else {
                        // Other errors (network, etc.)
                        let errorMsg = ErrorHandler.getErrorMessage(from: error, context: .general)
                        errorMessage = errorMsg
                    }
                    completion(false)
                }
            }
        }
    }
    
    func declineContract(
        contractId: String,
        completion: @escaping () -> Void
    ) {
        isLoading = true
        
        Task {
            do {
                _ = try await service.declineContract(id: contractId)
                await MainActor.run {
                    isLoading = false
                    completion()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = ErrorHandler.getErrorMessage(from: error, context: .general)
                }
            }
        }
    }
}

