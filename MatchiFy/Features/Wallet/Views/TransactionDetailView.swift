import SwiftUI

struct TransactionDetailView: View {
    let transaction: PaymentTransactionModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Status Icon
                statusIcon
                
                // Amount
                VStack(spacing: 8) {
                    Text(amountText)
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(amountColor)
                    
                    Text(transaction.status.rawValue.capitalized)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(statusColor.opacity(0.2))
                        .foregroundColor(statusColor)
                        .cornerRadius(8)
                }
                
                // Details
                VStack(spacing: 0) {
                    detailRow(title: "Mission ID", value: transaction.missionId)
                    Divider().padding(.leading)
                    detailRow(title: "Transaction ID", value: transaction.id)
                    Divider().padding(.leading)
                    detailRow(title: "Amount", value: String(format: "€%.2f", transaction.amount))
                    Divider().padding(.leading)
                    detailRow(title: "Platform Fee", value: String(format: "€%.2f", transaction.platformFee))
                    Divider().padding(.leading)
                    detailRow(title: "Talent Receives", value: String(format: "€%.2f", transaction.talentAmount))
                    Divider().padding(.leading)
                    detailRow(title: "Date", value: formattedDate)
                    
                    if let completedAt = transaction.completedAt {
                        Divider().padding(.leading)
                        detailRow(title: "Completed At", value: formatDate(completedAt))
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle("Transaction Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Components
    
    private var statusIcon: some View {
        Image(systemName: statusIconName)
            .font(.system(size: 60))
            .foregroundColor(statusColor)
            .frame(width: 100, height: 100)
            .background(statusColor.opacity(0.1))
            .clipShape(Circle())
    }
    
    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
        .padding()
    }
    
    // MARK: - Computed Properties
    
    private var amountText: String {
        let prefix = transaction.direction == .in ? "+" : "-"
        return prefix + String(format: "€%.2f", transaction.talentAmount)
    }
    
    private var amountColor: Color {
        transaction.direction == .in ? .green : .primary
    }
    
    private var statusIconName: String {
        switch transaction.status {
        case .completed: return "checkmark.circle.fill"
        case .pending, .processing: return "clock.fill"
        case .failed: return "xmark.circle.fill"
        case .refunded: return "arrow.uturn.backward.circle.fill"
        }
    }
    
    private var statusColor: Color {
        switch transaction.status {
        case .completed: return .green
        case .pending, .processing: return .orange
        case .failed, .refunded: return .red
        }
    }
    
    private var formattedDate: String {
        formatDate(transaction.createdAt)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
