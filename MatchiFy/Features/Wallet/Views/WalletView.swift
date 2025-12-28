import SwiftUI

struct WalletView: View {
    @StateObject private var viewModel = WalletViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Balance Card
                    if let summary = viewModel.walletSummary {
                        balanceCard(summary: summary)
                    }
                    
                    // Transactions Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Transactions")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if viewModel.transactions.isEmpty && !viewModel.isLoading {
                            emptyState
                        } else {
                            transactionsList
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Wallet")
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                await viewModel.loadWalletSummary()
                await viewModel.loadTransactions(refresh: true)
            }
            .overlay {
                if viewModel.isLoading && viewModel.walletSummary == nil {
                    ProgressView()
                }
            }
        }
    }
    
    // MARK: - Balance Card
    
    private func balanceCard(summary: WalletSummaryModel) -> some View {
        VStack(spacing: 16) {
            // Available Balance
            VStack(spacing: 4) {
                Text("Available Balance")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                
                Text(String(format: "€%.2f", summary.availableBalance))
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(AppTheme.Colors.primary)
            }
            
            // Stats Row
            HStack(spacing: 40) {
                if summary.role == "talent" {
                    statItem(title: "Pending", value: String(format: "€%.2f", summary.pendingBalance))
                    statItem(title: "Total Earned", value: String(format: "€%.2f", summary.totalEarned))
                } else {
                    statItem(title: "Total Spent", value: String(format: "€%.2f", summary.totalSpent))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        )
        .padding(.horizontal)
    }
    
    private func statItem(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
        }
    }
    
    // MARK: - Transactions List
    
    private var transactionsList: some View {
        LazyVStack(spacing: 0) {
            ForEach(viewModel.transactions, id: \.id) { transaction in
                NavigationLink(destination: TransactionDetailView(transaction: transaction)) {
                    TransactionRow(transaction: transaction, userRole: viewModel.walletSummary?.role ?? "talent")
                }
                .buttonStyle(PlainButtonStyle())
                
                if transaction.id != viewModel.transactions.last?.id {
                    Divider()
                        .padding(.leading, 60)
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "creditcard")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No Transactions Yet")
                .font(.headline)
            
            Text("Your transaction history will appear here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - Transaction Row

struct TransactionRow: View {
    let transaction: PaymentTransactionModel
    let userRole: String
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: iconName)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 44, height: 44)
                .background(iconColor.opacity(0.1))
                .clipShape(Circle())
            
            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.missionId)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Amount
            VStack(alignment: .trailing, spacing: 4) {
                Text(amountText)
                    .font(.headline)
                    .foregroundColor(amountColor)
                
                statusBadge
            }
        }
        .padding()
    }
    
    private var iconName: String {
        switch transaction.direction {
        case .in: return "arrow.down.circle.fill"
        case .out: return "arrow.up.circle.fill"
        }
    }
    
    private var iconColor: Color {
        switch transaction.direction {
        case .in: return .green
        case .out: return .orange
        }
    }
    
    private var amountText: String {
        let amount = userRole == "talent" ? transaction.talentAmount : transaction.amount
        let prefix = transaction.direction == .in ? "+" : "-"
        return "\(prefix)" + String(format: "€%.2f", amount)
    }
    
    private var amountColor: Color {
        transaction.direction == .in ? .green : .primary
    }
    
    private var statusBadge: some View {
        Text(transaction.status.rawValue.capitalized)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(4)
    }
    
    private var statusColor: Color {
        switch transaction.status {
        case .completed: return .green
        case .pending, .processing: return .orange
        case .failed, .refunded: return .red
        }
    }
    
    private var formattedDate: String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: transaction.createdAt.description) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return transaction.createdAt.description
    }
}
