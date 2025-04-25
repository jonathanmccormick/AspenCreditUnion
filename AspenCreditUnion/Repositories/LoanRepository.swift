import Foundation
import Combine

/// Repository that manages access to loan data
class LoanRepository {
  // MARK: - Dependencies
  
  /// Service that provides loan data
  private let loanService: LoanService
  
  // MARK: - Properties
  
  /// Cache of user loans for faster access
  private var loanCache: [String: [Loan]] = [:]
  
  // MARK: - Initialization
  
  /// Initializes a new loan repository
  /// - Parameter loanService: Service that provides loan data (defaults to mock implementation)
  init(loanService: LoanService = MockLoanService()) {
    self.loanService = loanService
  }
  
  // MARK: - Public Methods
  
  /// Fetches all loans for a user
  /// - Parameter userId: The ID of the user
  /// - Returns: A publisher that emits an array of loans or an error
  func getLoans(for userId: String) -> AnyPublisher<[Loan], Error> {
    // If we have cached loans for this user, return them
    if let cachedLoans = loanCache[userId] {
      return Just(cachedLoans)
        .setFailureType(to: Error.self)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    // Otherwise fetch from the service and cache the result
    return loanService.getLoans(for: userId)
      .handleEvents(receiveOutput: { [weak self] loans in
        self?.loanCache[userId] = loans
      })
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
  
  /// Fetches a specific loan by ID
  /// - Parameter loanId: The ID of the loan to fetch
  /// - Returns: A publisher that emits the loan or an error
  func getLoan(by loanId: String) -> AnyPublisher<Loan, Error> {
    // Check if we have this loan in our cache
    for (_, loans) in loanCache {
      if let loan = loans.first(where: { $0.id == loanId }) {
        return Just(loan)
          .setFailureType(to: Error.self)
          .receive(on: DispatchQueue.main)
          .eraseToAnyPublisher()
      }
    }
    
    // If not found in cache, fetch from the service
    return loanService.getLoan(by: loanId)
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
  
  /// Makes a payment on a loan
  /// - Parameters:
  ///   - loanId: The ID of the loan
  ///   - amount: The payment amount
  ///   - fromAccountId: The account to withdraw the payment from
  /// - Returns: A publisher that emits the updated loan or an error
  func makePayment(loanId: String, amount: Decimal, fromAccountId: String) -> AnyPublisher<Loan, Error> {
    // Clear the cache for this loan since we're making a change
    invalidateLoanCache(loanId: loanId)
    
    return loanService.makePayment(loanId: loanId, amount: amount, fromAccountId: fromAccountId)
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
  
  /// Clears the loan cache
  func clearCache() {
    loanCache.removeAll()
  }
  
  // MARK: - Private Methods
  
  /// Invalidates cache entries containing a specific loan
  /// - Parameter loanId: The ID of the loan to invalidate
  private func invalidateLoanCache(loanId: String) {
    for (userId, loans) in loanCache where loans.contains(where: { $0.id == loanId }) {
      loanCache.removeValue(forKey: userId)
      break
    }
  }
}
