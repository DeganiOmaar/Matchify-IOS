import SwiftUI

struct ContractDetailView: View {
    let contract: ContractModel
    @Environment(\.dismiss) private var dismiss
    @State private var pdfUrl: URL?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(contract.title)
                        .font(.title2)
                        .bold()
                    
                    Text(contract.content)
                        .font(.body)
                    
                    if let paymentDetails = contract.paymentDetails {
                        Text("Payment details: \(paymentDetails)")
                            .font(.subheadline)
                    }
                    
                    if let startDate = contract.startDate {
                        Text("Start date: \(formatDate(startDate))")
                            .font(.subheadline)
                    }
                    
                    if let endDate = contract.endDate {
                        Text("End date: \(formatDate(endDate))")
                            .font(.subheadline)
                    }
                    
                    Text("Status: \(contract.status.displayName)")
                        .font(.subheadline)
                        .foregroundColor(contract.status == .signedByBoth ? .green : .orange)
                    
                    // Show signatures section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Signatures:")
                            .font(.headline)
                        
                        // Recruiter signature - always show if present
                        if !contract.recruiterSignature.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Recruiter:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                if let recruiterSigImage = imageFromBase64(contract.recruiterSignature) {
                                    Image(uiImage: recruiterSigImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 80)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        
                        // Talent signature - only show if contract is signed by both
                        if contract.status == .signedByBoth,
                           let talentSignature = contract.talentSignature,
                           !talentSignature.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Talent:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                if let talentSigImage = imageFromBase64(talentSignature) {
                                    Image(uiImage: talentSigImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 80)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                }
                            }
                        } else if contract.status != .signedByBoth {
                            // Show placeholder if contract not yet signed by talent
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Talent:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("Pending signature")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .italic()
                                    .frame(height: 80)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // PDF link - prioritize signed PDF
                    if let pdfUrlString = contract.signedPdfUrl ?? contract.pdfUrl {
                        let fullUrl = pdfUrlString.hasPrefix("http") ? pdfUrlString : Endpoints.baseURL + pdfUrlString
                        if let url = URL(string: fullUrl) {
                            Link("View PDF", destination: url)
                                .font(.headline)
                                .foregroundColor(.blue)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Contract Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withFullDate]
        if let date = iso.date(from: dateString) {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "fr_FR")
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
        return dateString
    }
    
    private func imageFromBase64(_ base64String: String) -> UIImage? {
        // Remove data URL prefix if present
        let base64 = base64String.replacingOccurrences(of: "data:image/[^;]+;base64,", with: "", options: .regularExpression)
        
        guard let imageData = Data(base64Encoded: base64) else {
            return nil
        }
        return UIImage(data: imageData)
    }
}

