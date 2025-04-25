import Foundation
import Combine

/// ViewModel that provides data for the home screen of the banking app
@MainActor
final class HomeViewModel: ObservableObject {
  // MARK: - Published Properties
  
  /// The currently authenticated user
  @Published private(set) var user: User?
  /// Collection of user's bank accounts
  @Published private(set) var accounts: [Account] = []
  /// Collection of user's loans
  @Published private(set) var loans: [Loan] = []
  /// Indicates whether data is currently being loaded
  @Published private(set) var isLoading: Bool = false
  /// Error message to display if data loading fails
  @Published private(set) var errorMessage: String?
  
  // MARK: - Dependencies
  
  /// Repository that provides user data
  private let userRepository: UserRepository
  /// Repository that provides account data
  private let accountRepository: AccountRepository
  /// Repository that provides loan data
  private let loanRepository: LoanRepository
  
  // MARK: - Private Properties
  
  /// Set of cancellable subscribers
  private var cancellables = Set<AnyCancellable>()
  
  // MARK: - Initialization
  
  /// Initializes a new home screen view model
  /// - Parameters:
  ///   - userRepository: Repository that provides user data
  ///   - accountRepository: Repository that provides account data
  ///   - loanRepository: Repository that provides loan data
  init(
    userRepository: UserRepository = UserRepository(),
    accountRepository: AccountRepository = AccountRepository(),
    loanRepository: LoanRepository = LoanRepository()
  ) {
    self.userRepository = userRepository
    self.accountRepository = accountRepository
    self.loanRepository = loanRepository
  }
  
  // MARK: - Public Methods
  
  /// Loads all data needed for the home screen
  func loadData() {
    isLoading = true
    errorMessage = nil
    
    // First fetch the user
    userRepository.getCurrentUser()
      .flatMap { [weak self] user -> AnyPublisher<(User, [Account], [Loan]), Error> in
        guard let self = self else {
          return Fail(error: NSError(domain: "HomeViewModel", code: 0, userInfo: nil))
            .eraseToAnyPublisher()
        }
        
        // Once we have the user, fetch their accounts and loans in parallel
        return Publishers.Zip3(
          Just(user).setFailureType(to: Error.self),
          self.accountRepository.getAccounts(for: user.id),
          self.loanRepository.getLoans(for: user.id)
        ).eraseToAnyPublisher()
      }
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { [weak self] completion in
          self?.isLoading = false
          
          if case .failure(let error) = completion {
            self?.errorMessage = error.localizedDescription
          }
        },
        receiveValue: { [weak self] user, accounts, loans in
          self?.user = user
          self?.accounts = accounts
          self?.loans = loans
        }
      )
      .store(in: &cancellables)
  }
  
  /// Refreshes all data
  func refreshData() {
    // Clear caches to ensure fresh data
    accountRepository.clearCache()
    loanRepository.clearCache()
    
    // Reload all data
    loadData()
  }
  
  // MARK: - Computed Properties
  
  /// Total balance across all accounts
  var totalAccountBalance: Decimal {
    accounts.reduce(0) { $0 + $1.balance }
  }
  
  /// Total debt across all loans
  var totalLoanBalance: Decimal {
    loans.reduce(0) { $0 + $1.currentBalance }
  }
  
  /// Net worth (total assets minus total debts)
  var netWorth: Decimal {
    totalAccountBalance - totalLoanBalance
  }
}