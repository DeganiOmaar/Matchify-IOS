import Foundation
import Combine

@MainActor
class WalletViewModel: ObservableObject {
    @Published var walletSummary: WalletSummaryModel?
    @Published var transactions: [PaymentTransactionModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let walletService = WalletService.shared
    private var currentPage = 1
    private var hasMorePages = true
    
    // MARK: - Load Wallet Data
    
    func loadWalletSummary() async {
        isLoading = true
        errorMessage = nil
        
        do {
            walletSummary = try await walletService.getWalletSummary()
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = ErrorHandler.getErrorMessage(from: error, context: .general)
        }
    }
    
    func loadTransactions(refresh: Bool = false) async {
        if refresh {
            currentPage = 1
            hasMorePages = true
            transactions = []
        }
        
        guard hasMorePages else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await walletService.getTransactions(page: currentPage, limit: 20)
            
            if refresh {
                transactions = response.transactions
            } else {
                transactions.append(contentsOf: response.transactions)
            }
            
            hasMorePages = currentPage < response.pages
            currentPage += 1
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = ErrorHandler.getErrorMessage(from: error, context: .general)
        }
    }
    
    func loadMore() async {
        await loadTransactions(refresh: false)
    }
    
    func refresh() async {
        await loadWalletSummary()
        await loadTransactions(refresh: true)
    }
}
