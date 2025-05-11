import Foundation

class TransactionService {
    static let shared = TransactionService()
    private let apiClient = APIClient.shared
    
    private init() {}
    
    // Get transaction history
    func getTransactionHistory() async throws -> [Transaction] {
        return try await apiClient.request(endpoint: .getTransactionHistory)
    }
    
    // Transfer between accounts
    func transferBetweenAccounts(sourceAccountId: String, destinationAccountId: String, amount: Decimal, description: String? = nil) async throws -> Transaction {
        let request = TransactionRequest(
            type: .transfer,
            sourceAccountId: sourceAccountId,
            destinationAccountId: destinationAccountId,
            amount: amount,
            description: description
        )
        return try await apiClient.request(endpoint: .createTransaction, body: request)
    }
    
    // Make a loan payment
    func makeLoanPayment(sourceAccountId: String, loanId: String, amount: Decimal, description: String? = nil) async throws -> Transaction {
        let request = TransactionRequest(
            type: .loanPayment,
            sourceAccountId: sourceAccountId,
            destinationAccountId: loanId,
            amount: amount,
            description: description
        )
        return try await apiClient.request(endpoint: .createTransaction, body: request)
    }
    
    // Request a loan advance
    func requestLoanAdvance(loanId: String, destinationAccountId: String, amount: Decimal, description: String? = nil) async throws -> Transaction {
        let request = TransactionRequest(
            type: .loanAdvance,
            sourceAccountId: loanId,
            destinationAccountId: destinationAccountId,
            amount: amount,
            description: description
        )
        return try await apiClient.request(endpoint: .createTransaction, body: request)
    }
}