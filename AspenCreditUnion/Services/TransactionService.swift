import Foundation
import Combine

/// Protocol defining transaction data access operations
protocol TransactionService {
  /// Fetches transactions for a specific account
  /// - Parameters:
  ///   - accountId: The ID of the account
  ///   - limit: Maximum number of transactions to fetch (optional)
  /// - Returns: A publisher that emits an array of transactions or an error
  func getTransactions(for accountId: String, limit: Int?) -> AnyPublisher<[Transaction], Error>
  
  /// Fetches a specific transaction by ID
  /// - Parameter transactionId: The ID of the transaction
  /// - Returns: A publisher that emits the transaction or an error
  func getTransaction(by transactionId: String) -> AnyPublisher<Transaction, Error>
  
  /// Creates a transfer between accounts
  /// - Parameters:
  ///   - fromAccountId: The source account ID
  ///   - toAccountId: The destination account ID
  ///   - amount: The amount to transfer
  ///   - description: Description of the transfer
  /// - Returns: A publisher that emits the created transaction or an error
  func createTransfer(fromAccountId: String, toAccountId: String, amount: Decimal, description: String) -> AnyPublisher<Transaction, Error>
}

/// Mock implementation of TransactionService that provides hardcoded data
class MockTransactionService: TransactionService {
  /// Collection of mock transactions
  private var mockTransactions = [
    // Checking account transactions
    Transaction(
      id: "txn_123456",
      accountId: "acc_checking_123",
      date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
      amount: -85.43,
      description: "Grocery Store Purchase",
      merchant: "Whole Foods",
      category: .food,
      status: .completed,
      type: .debit
    ),
    Transaction(
      id: "txn_123457",
      accountId: "acc_checking_123",
      date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
      amount: -45.00,
      description: "Monthly Subscription",
      merchant: "Streaming Service",
      category: .entertainment,
      status: .completed,
      type: .debit
    ),
    Transaction(
      id: "txn_123458",
      accountId: "acc_checking_123",
      date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
      amount: 1500.00,
      description: "Direct Deposit",
      merchant: "Employer",
      category: .income,
      status: .completed,
      type: .credit
    ),
    Transaction(
      id: "txn_123459",
      accountId: "acc_checking_123",
      date: Calendar.current.date(byAdding: .hour, value: -4, to: Date())!,
      amount: -45.00,
      description: "Gas Station",
      merchant: "Shell",
      category: .transportation,
      status: .pending,
      type: .debit
    ),
    
    // Savings account transactions
    Transaction(
      id: "txn_234567",
      accountId: "acc_savings_456",
      date: Calendar.current.date(byAdding: .day, value: -10, to: Date())!,
      amount: 500.00,
      description: "Transfer from Checking",
      merchant: nil,
      category: .transfer,
      status: .completed,
      type: .credit
    ),
    Transaction(
      id: "txn_234568",
      accountId: "acc_savings_456",
      date: Calendar.current.date(byAdding: .day, value: -20, to: Date())!,
      amount: 25.50,
      description: "Interest Payment",
      merchant: nil,
      category: .income,
      status: .completed,
      type: .interest
    )
  ]
  
  /// Simulates fetching transactions for an account from a database/API
  /// - Parameters:
  ///   - accountId: Account to fetch transactions for
  ///   - limit: Optional maximum number of records to return
  /// - Returns: A publisher with matching transactions
  func getTransactions(for accountId: String, limit: Int? = nil) -> AnyPublisher<[Transaction], Error> {
    var filteredTransactions = mockTransactions.filter { $0.accountId == accountId }
    
    // Sort by date, newest first
    filteredTransactions.sort { $0.date > $1.date }
    
    // Apply limit if specified
    if let limit = limit {
      filteredTransactions = Array(filteredTransactions.prefix(limit))
    }
    
    return Just(filteredTransactions)
      .setFailureType(to: Error.self)
      .eraseToAnyPublisher()
  }
  
  /// Simulates fetching a specific transaction by ID
  /// - Parameter transactionId: Transaction ID to fetch
  /// - Returns: A publisher with the matching transaction or error
  func getTransaction(by transactionId: String) -> AnyPublisher<Transaction, Error> {
    guard let transaction = mockTransactions.first(where: { $0.id == transactionId }) else {
      return Fail(error: NSError(domain: "TransactionService", code: 404, userInfo: nil))
        .eraseToAnyPublisher()
    }
    
    return Just(transaction)
      .setFailureType(to: Error.self)
      .eraseToAnyPublisher()
  }
  
  /// Simulates creating a transfer between accounts
  /// - Parameters:
  ///   - fromAccountId: Source account ID
  ///   - toAccountId: Destination account ID
  ///   - amount: Amount to transfer
  ///   - description: Transaction description
  /// - Returns: A publisher with the created transaction
  func createTransfer(fromAccountId: String, toAccountId: String, amount: Decimal, description: String) -> AnyPublisher<Transaction, Error> {
    // Generate a unique transaction ID
    let newTransactionId = "txn_" + UUID().uuidString.prefix(6)
    
    // Create the withdrawal transaction from source account
    let withdrawalTransaction = Transaction(
      id: newTransactionId,
      accountId: fromAccountId,
      date: Date(),
      amount: -abs(amount),
      description: description,
      merchant: nil,
      category: .transfer,
      status: .completed,
      type: .transfer
    )
    
    // Create the deposit transaction to destination account
    let depositTransaction = Transaction(
      id: "txn_" + UUID().uuidString.prefix(6),
      accountId: toAccountId,
      date: Date(),
      amount: abs(amount),
      description: description,
      merchant: nil,
      category: .transfer,
      status: .completed,
      type: .transfer
    )
    
    // Add both transactions to our mock database
    mockTransactions.append(withdrawalTransaction)
    mockTransactions.append(depositTransaction)
    
    // Return the withdrawal transaction as the result
    return Just(withdrawalTransaction)
      .setFailureType(to: Error.self)
      .eraseToAnyPublisher()
  }
}
