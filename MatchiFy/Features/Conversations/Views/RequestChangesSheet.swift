import SwiftUI

struct RequestChangesSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ConversationViewModel
    let deliverableId: String
    
    @State private var reason: String = ""
    @State private var isSubmitting = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Please explain what changes are needed. The talent will be notified directly.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                TextEditor(text: $reason)
                    .frame(height: 150)
                    .padding(8)
                    .background(AppTheme.Colors.secondaryBackground)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal)
                
                Spacer()
                
                Button {
                    submit()
                } label: {
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Request Changes")
                            .bold()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(reason.isEmpty ? Color.gray.opacity(0.3) : AppTheme.Colors.primary)
                .foregroundColor(.white)
                .cornerRadius(12)
                .disabled(reason.isEmpty || isSubmitting)
                .padding()
            }
            .navigationTitle("Request Changes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func submit() {
        guard !reason.isEmpty else { return }
        isSubmitting = true
        
        // Call ViewModel to update status
        viewModel.updateDeliverableStatus(
            deliverableId: deliverableId,
            status: "revision_requested",
            reason: reason
        )
        
        // Delay dismiss slightly to allow VM to start task (VM handles async but sheet can close)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismiss()
        }
    }
}
