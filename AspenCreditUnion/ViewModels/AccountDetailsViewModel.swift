import Foundation
import Combine

/// ViewModel that provides data for the account details screen
@MainActor
final class AccountDetailsViewModel: ObservableObject {
  // MARK: - Published Properties
  
  /// The account being displayed
  @Published private(set) var account: Account?
  /// Transactions for this account
  @Published private(set) var transactions: [Transaction] = []
  /// Indicates whether data is currently being loaded
  @Published private(set) var isLoading: Bool = false
  /// Error message to display if data loading fails
  @Published private(set) var errorMessage: String?
  
  // MARK: - Dependencies
  
  /// Repository that provides account data
  private let accountRepository: AccountRepository
  /// Repository that provides transaction data
  private let transactionRepository: TransactionRepository
  
  // MARK: - Private Properties
  
  /// ID of the account to display
  private let accountId: String
  /// Maximum number of transactions to initially load
  private let initialTransactionLimit = 20
  /// Set of cancellable subscribers
  private var cancellables = Set<AnyCancellable>()
  
  // MARK: - Initialization
  
  /// Initializes a new account details view model
  /// - Parameters:
  ///   - accountId: ID of the account to display
  ///   - accountRepository: Repository that provides account data
  ///   - transactionRepository: Repository that provides transaction data
  init(
    accountId: String,
    accountRepository: AccountRepository = AccountRepository(),
    transactionRepository: TransactionRepository = TransactionRepository()
  ) {
    self.accountId = accountId
    self.accountRepository = accountRepository
    self.transactionRepository = transactionRepository
  }
  
  // MARK: - Public Methods
  
  /// Loads account details and recent transactions
  func loadData() {
    isLoading = true
    errorMessage = nil
    
    // Fetch the account and its transactions in parallel
    Publishers.Zip(
      accountRepository.getAccount(by: accountId),
      transactionRepository.getTransactions(for: accountId, limit: initialTransactionLimit)
    )
    .receive(on: DispatchQueue.main)
    .sink(
      receiveCompletion: { [weak self] completion in
        self?.isLoading = false
        
        if case .failure(let error) = completion {
          self?.errorMessage = error.localizedDescription
        }
      },
      receiveValue: { [weak self] account, transactions in
        self?.account = account
        self?.transactions = transactions
      }
    )
    .store(in: &cancellables)
  }
  
  /// Loads all transactions for this account
  func loadAllTransactions() {
    isLoading = true
    
    transactionRepository.getTransactions(for: accountId, limit: nil)
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { [weak self] completion in
          self?.isLoading = false
          
          if case .failure(let error) = completion {
            self?.errorMessage = error.localizedDescription
          }
        },
        receiveValue: { [weak self] transactions in
          self?.transactions = transactions
        }
      )
      .store(in: &cancellables)
  }
  
  /// Refreshes all data
  func refreshData() {
    // Clear caches to ensure fresh data
    transactionRepository.clearCache()
    
    // Reload data
    loadData()
  }
  
  /// Creates a transfer from this account to another account
  /// - Parameters:
  ///   - toAccountId: Destination account ID
  ///   - amount: Amount to transfer
  ///   - description: Transaction description
  /// - Returns: A publisher that emits when the transfer is complete or an error
  func createTransfer(toAccountId: String, amount: Decimal, description: String) -> AnyPublisher<Void, Error> {
    transactionRepository.createTransfer(
      fromAccountId: accountId,
      toAccountId: toAccountId,
      amount: amount,
      description: description
    )
    .map { _ in () }
    .handleEvents(receiveCompletion: { [weak self] completion in
      if case .finished = completion {
        self?.refreshData()
      }
    })
    .eraseToAnyPublisher()
  }
  
  // MARK: - Computed Properties
  
  /// Number of pending transactions
  var pendingTransactionsCount: Int {
    transactions.filter { $0.isPending }.count
  }
  
  /// Total amount of pending transactions
  var pendingTransactionsAmount: Decimal {
    transactions.filter { $0.isPending }.reduce(0) { $0 + $1.amount }
  }
}
