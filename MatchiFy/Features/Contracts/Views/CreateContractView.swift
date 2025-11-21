import SwiftUI
import Combine

struct CreateContractView: View {
    let missionId: String
    let talentId: String
    let onContractCreated: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CreateContractViewModel()
    @State private var signatureImage: UIImage?
    @State private var showSignaturePad = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Informations du contrat")) {
                    TextField("Titre du contrat", text: $viewModel.title)
                    TextField("Termes du contrat", text: $viewModel.content, axis: .vertical)
                        .lineLimit(3...10)
                    TextField("Détails de paiement", text: Binding(
                        get: { viewModel.paymentDetails ?? "" },
                        set: { viewModel.paymentDetails = $0.isEmpty ? nil : $0 }
                    ))
                }
                
                Section(header: Text("Dates")) {
                    DatePicker("Date de début", selection: Binding(
                        get: { viewModel.startDate ?? Date() },
                        set: { viewModel.startDate = $0 }
                    ), displayedComponents: .date)
                    DatePicker("Date de fin", selection: Binding(
                        get: { viewModel.endDate ?? Date() },
                        set: { viewModel.endDate = $0 }
                    ), displayedComponents: .date)
                }
                
                Section(header: Text("Signature")) {
                    if let signature = signatureImage {
                        Image(uiImage: signature)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                    }
                    Button("Signer") {
                        showSignaturePad = true
                    }
                }
            }
            .navigationTitle("Nouveau contrat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Envoyer") {
                        viewModel.createContract(
                            missionId: missionId,
                            talentId: talentId,
                            signature: signatureImage
                        ) {
                            onContractCreated()
                            dismiss()
                        }
                    }
                    .disabled(viewModel.title.isEmpty || viewModel.content.isEmpty || signatureImage == nil)
                }
            }
            .sheet(isPresented: $showSignaturePad) {
                SignaturePadView(image: $signatureImage)
            }
        }
    }
}

@MainActor
final class CreateContractViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var content: String = ""
    @Published var paymentDetails: String?
    @Published var startDate: Date?
    @Published var endDate: Date?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let service = ContractService.shared
    
    func createContract(
        missionId: String,
        talentId: String,
        signature: UIImage?,
        completion: @escaping () -> Void
    ) {
        guard let signature = signature,
              let signatureData = signature.pngData() else {
            return
        }
        let base64Signature = signatureData.base64EncodedString()
        
        isLoading = true
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]
        
        let request = CreateContractRequest(
            missionId: missionId,
            talentId: talentId,
            title: title,
            content: content,
            paymentDetails: paymentDetails,
            startDate: startDate != nil ? dateFormatter.string(from: startDate!) : nil,
            endDate: endDate != nil ? dateFormatter.string(from: endDate!) : nil,
            recruiterSignature: "data:image/png;base64,\(base64Signature)"
        )
        
        Task {
            do {
                _ = try await service.createContract(request)
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

