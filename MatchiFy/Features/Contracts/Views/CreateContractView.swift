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
                Section(header: Text("Contract Information")) {
                    TextField("Contract Title", text: $viewModel.title)
                    TextField("Project Scope and Deliverables", text: $viewModel.scope, axis: .vertical)
                        .lineLimit(3...10)
                    TextField("Budget and Payment Terms", text: $viewModel.budget)
                    TextField("Payment Details (optional)", text: Binding(
                        get: { viewModel.paymentDetails ?? "" },
                        set: { viewModel.paymentDetails = $0.isEmpty ? nil : $0 }
                    ))
                }
                
                Section(header: Text("Dates")) {
                    DatePicker("Start Date", selection: $viewModel.startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $viewModel.endDate, displayedComponents: .date)
                }
                
                Section(header: Text("Signature")) {
                    if let signature = signatureImage {
                        Image(uiImage: signature)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                    }
                    Button("Sign") {
                        showSignaturePad = true
                    }
                }
            }
            .navigationTitle("New Contract")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Send") {
                        viewModel.createContract(
                            missionId: missionId,
                            talentId: talentId,
                            signature: signatureImage
                        ) {
                            onContractCreated()
                            dismiss()
                        }
                    }
                    .disabled(viewModel.title.isEmpty || viewModel.scope.isEmpty || viewModel.budget.isEmpty || signatureImage == nil)
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
    @Published var scope: String = ""
    @Published var budget: String = ""
    @Published var paymentDetails: String?
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
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
            scope: scope,
            budget: budget,
            startDate: dateFormatter.string(from: startDate),
            endDate: dateFormatter.string(from: endDate),
            paymentDetails: paymentDetails,
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

