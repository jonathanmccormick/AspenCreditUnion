import Foundation
import Combine
import SwiftUI

/// ViewModel that provides data for the loan details screen
@MainActor
final class LoanDetailsViewModel: ObservableObject {
  // MARK: - Published Properties
  
  /// The loan being displayed
  @Published private(set) var loan: Loan?
  /// Indicates whether data is currently being loaded
  @Published private(set) var isLoading: Bool = false
  /// Error message to display if data loading fails
  @Published private(set) var errorMessage: String?
  /// Payment history for this loan
  @Published private(set) var paymentHistory: [Transaction] = []
  
  // MARK: - Dependencies
  
  /// Repository that provides loan data
  private let loanRepository: LoanRepository
  /// Repository that provides transaction data
  private let transactionRepository: TransactionRepository
  /// Repository that provides account data
  private let accountRepository: AccountRepository
  
  // MARK: - Private Properties
  
  /// ID of the loan to display
  private let loanId: String
  /// Set of cancellable subscribers
  private var cancellables = Set<AnyCancellable>()
  
  // MARK: - Initialization
  
  /// Initializes a new loan details view model
  /// - Parameters:
  ///   - loanId: ID of the loan to display
  ///   - loanRepository: Repository that provides loan data
  ///   - transactionRepository: Repository that provides transaction data
  ///   - accountRepository: Repository that provides account data
  init(
    loanId: String,
    loanRepository: LoanRepository = LoanRepository(),
    transactionRepository: TransactionRepository = TransactionRepository(),
    accountRepository: AccountRepository = AccountRepository()
  ) {
    self.loanId = loanId
    self.loanRepository = loanRepository
    self.transactionRepository = transactionRepository
    self.accountRepository = accountRepository
  }
  
  // MARK: - Public Methods
  
  /// Loads loan details
  func loadData() {
    isLoading = true
    errorMessage = nil
    
    // Fetch the loan details
    loanRepository.getLoan(by: loanId)
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { [weak self] completion in
          if case .failure(let error) = completion {
            self?.isLoading = false
            self?.errorMessage = error.localizedDescription
          }
        },
        receiveValue: { [weak self] loan in
          self?.loan = loan
          self?.loadPaymentHistory()
        }
      )
      .store(in: &cancellables)
  }
  
  /// Refreshes all data
  func refreshData() {
    // Clear caches to ensure fresh data
    loanRepository.clearCache()
    
    // Reload all data
    loadData()
  }
  
  /// Makes a payment on this loan
  /// - Parameters:
  ///   - amount: Amount to pay
  ///   - fromAccountId: Source account for the payment
  /// - Returns: A publisher that emits when the payment is complete or fails
  func makePayment(amount: Decimal, fromAccountId: String) -> AnyPublisher<Void, Error> {
    isLoading = true
    
    return loanRepository.makePayment(
      loanId: loanId,
      amount: amount,
      fromAccountId: fromAccountId
    )
    .map { _ in () }
    .handleEvents(
      receiveCompletion: { [weak self] completion in
        self?.isLoading = false
        if case .finished = completion {
          self?.refreshData()
        }
      },
      receiveCancel: { [weak self] in
        self?.isLoading = false
      }
    )
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
  }
  
  /// Loads available user accounts that can be used for payments
  /// - Returns: A publisher that emits accounts or an error
  func loadAvailableAccounts() -> AnyPublisher<[Account], Error> {
    guard let userId = loan?.userId else {
      return Fail(error: NSError(domain: "LoanDetailsViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "User ID not available"]))
        .eraseToAnyPublisher()
    }
    
    return accountRepository.getAccounts(for: userId)
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
  
  // MARK: - Private Methods
  
  /// Loads payment history for this loan
  private func loadPaymentHistory() {
    // In a real app, we would fetch actual payment history for the loan
    // For this demo, we'll simulate by creating some payment transactions
    let mockPayments = createMockPaymentHistory()
    
    DispatchQueue.main.async {
      self.paymentHistory = mockPayments
      self.isLoading = false
    }
  }
  
  /// Creates mock payment history for demo purposes
  /// - Returns: Array of mock payment transactions
  private func createMockPaymentHistory() -> [Transaction] {
    guard let loan = loan else { return [] }
    
    // Create mock payment history covering the last 6 months
    var payments: [Transaction] = []
    let calendar = Calendar.current
    
    for i in 1...6 {
      let paymentDate = calendar.date(byAdding: .month, value: -i, to: Date()) ?? Date()
      
      payments.append(
        Transaction(
          id: "txn_payment_\(UUID().uuidString.prefix(8))",
          accountId: "acc_checking_123", // Assume from checking account
          date: paymentDate,
          amount: -loan.monthlyPayment, // Negative because it's money out
          description: "Payment to \(loan.name)",
          merchant: nil,
          category: .payment,
          status: .completed,
          type: .payment
        )
      )
    }
    
    return payments.sorted(by: { $0.date > $1.date }) // Most recent first
  }
  
  // MARK: - Computed Properties
  
  /// Total amount paid toward this loan
  var totalPaid: Decimal {
    guard let loan = loan else { return 0 }
    return loan.originalPrincipal - loan.currentBalance
  }
  
  /// Percentage of the total loan amount that has been paid
  var percentagePaid: Double {
    guard let loan = loan else { return 0 }
    return loan.payoffPercentage
  }
  
  /// Formatted interest rate string
  var formattedInterestRate: String {
    guard let loan = loan else { return "0.00%" }
    
    let formatter = NumberFormatter()
    formatter.numberStyle = .percent
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    
    return formatter.string(from: NSDecimalNumber(decimal: loan.interestRate)) ?? "0.00%"
  }
  
  /// Number of days until next payment is due
  var daysUntilNextPayment: Int? {
    guard let loan = loan else { return nil }
    return Calendar.current.dateComponents([.day], from: Date(), to: loan.nextPaymentDue).day
  }
}