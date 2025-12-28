import SwiftUI
import Combine
import StripePaymentSheet

struct MissionPaymentView: View {
    let mission: MissionModel
    let userRole: String
    var onPaymentSuccess: (() -> Void)? = nil
    @StateObject private var viewModel = MissionPaymentViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            if userRole == "talent" {
                talentCompleteView
            } else {
                recruiterApproveView
            }
        }
        .padding()
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .alert("Success", isPresented: .constant(viewModel.successMessage != nil)) {
            Button("OK") {
                viewModel.successMessage = nil
                dismiss()
            }
        } message: {
            Text(viewModel.successMessage ?? "")
        }
        .overlay {
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                }
            }
        }
    }
    
    // MARK: - Talent View
    
    private var talentCompleteView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Mark Mission as Complete")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Once you mark this mission as complete, the recruiter will be notified to review and approve payment.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                Task {
                    await viewModel.completeMission(missionId: mission.missionId)
                }
            } label: {
                Text("Mark as Complete")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
            }
            
            Button("Cancel") {
                dismiss()
            }
            .foregroundColor(.secondary)
        }
    }
    
// MARK: - Recruiter View
    
    private var recruiterApproveView: some View {
        VStack(spacing: 16) {
            Image(systemName: "creditcard.fill")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.primary)
            
            Text("Approve & Pay")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 12) {
                paymentDetailRow(title: "Mission Budget", value: "€\(mission.budget)")
                paymentDetailRow(title: "Platform Fee (3%)", value: "€\(Int(Double(mission.budget) * 0.03))")
                Divider()
                paymentDetailRow(title: "Talent Receives", value: "€\(mission.budget - Int(Double(mission.budget) * 0.03))", bold: true)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            Text("By approving, you authorize payment to the talent. The amount will be charged to your default payment method.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if let paymentSheet = viewModel.paymentSheet {
                PaymentSheet.PaymentButton(
                    paymentSheet: paymentSheet,
                    onCompletion: { result in
                        viewModel.onPaymentCompletion(result: result, missionId: mission.missionId)
                    }
                ) {
                    Text("Pay & Approve €\(mission.budget)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.Colors.primary)
                        .cornerRadius(12)
                }
            } else {
                Button {
                    viewModel.initiatePayment(missionId: mission.missionId)
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Prepare Payment")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppTheme.Colors.primary)
                .cornerRadius(12)
                .disabled(viewModel.isLoading)
            }
            
            Button("Cancel") {
                dismiss()
            }
            .foregroundColor(.secondary)
        }
        .onChange(of: viewModel.isSuccess) { success in
            if success {
                onPaymentSuccess?()
                dismiss()
            }
        }
    }
    
    private func paymentDetailRow(title: String, value: String, bold: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(bold ? .headline : .subheadline)
            Spacer()
            Text(value)
                .font(bold ? .headline : .subheadline)
                .fontWeight(bold ? .bold : .regular)
        }
    }
}
