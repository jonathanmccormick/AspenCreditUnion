import Foundation
import Combine

/// Repository that manages access to transaction data
class TransactionRepository {
  // MARK: - Dependencies
  
  /// Service that provides transaction data
  private let transactionService: TransactionService
  
  // MARK: - Properties
  
  /// Cache of account transactions for faster access
  private var transactionCache: [String: [Transaction]] = [:]
  
  // MARK: - Initialization
  
  /// Initializes a new transaction repository
  /// - Parameter transactionService: Service that provides transaction data (defaults to mock implementation)
  init(transactionService: TransactionService = MockTransactionService()) {
    self.transactionService = transactionService
  }
  
  // MARK: - Public Methods
  
  /// Fetches transactions for a specific account
  /// - Parameters:
  ///   - accountId: The ID of the account
  ///   - limit: Maximum number of transactions to fetch (optional)
  /// - Returns: A publisher that emits an array of transactions or an error
  func getTransactions(for accountId: String, limit: Int? = nil) -> AnyPublisher<[Transaction], Error> {
    // Use cached transactions if available and no limit is specified or limit matches cached count
    let cachedTransactions = transactionCache[accountId]
    if let cachedTransactions = cachedTransactions,
       (limit == nil || cachedTransactions.count <= limit!) {
      return Just(limit != nil ? Array(cachedTransactions.prefix(limit!)) : cachedTransactions)
        .setFailureType(to: Error.self)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    // Otherwise fetch from the service and cache the result
    return transactionService.getTransactions(for: accountId, limit: limit)
      .handleEvents(receiveOutput: { [weak self] transactions in
        // Only cache if we're fetching all transactions (no limit)
        if limit == nil {
          self?.transactionCache[accountId] = transactions
        }
      })
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
  
  /// Fetches a specific transaction by ID
  /// - Parameter transactionId: The ID of the transaction
  /// - Returns: A publisher that emits the transaction or an error
  func getTransaction(by transactionId: String) -> AnyPublisher<Transaction, Error> {
    // Check if we have this transaction in our cache
    for (_, transactions) in transactionCache {
      if let transaction = transactions.first(where: { $0.id == transactionId }) {
        return Just(transaction)
          .setFailureType(to: Error.self)
          .receive(on: DispatchQueue.main)
          .eraseToAnyPublisher()
      }
    }
    
    // If not found in cache, fetch from the service
    return transactionService.getTransaction(by: transactionId)
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
  
  /// Creates a transfer between accounts
  /// - Parameters:
  ///   - fromAccountId: The source account ID
  ///   - toAccountId: The destination account ID
  ///   - amount: The amount to transfer
  ///   - description: Description of the transfer
  /// - Returns: A publisher that emits the created transaction or an error
  func createTransfer(fromAccountId: String, toAccountId: String, amount: Decimal, description: String) -> AnyPublisher<Transaction, Error> {
    // Clear the cache for both accounts since we're making a change
    invalidateTransactionCache(accountIds: [fromAccountId, toAccountId])
    
    return transactionService.createTransfer(fromAccountId: fromAccountId, toAccountId: toAccountId, amount: amount, description: description)
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
  
  /// Clears the transaction cache
  func clearCache() {
    transactionCache.removeAll()
  }
  
  // MARK: - Private Methods
  
  /// Invalidates cache entries for specific accounts
  /// - Parameter accountIds: The account IDs to invalidate the cache for
  private func invalidateTransactionCache(accountIds: [String]) {
    for accountId in accountIds {
      transactionCache.removeValue(forKey: accountId)
    }
  }
}