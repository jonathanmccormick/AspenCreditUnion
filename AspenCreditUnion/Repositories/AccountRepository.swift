import Foundation
import Combine

/// Repository that manages access to account data
class AccountRepository {
  // MARK: - Dependencies
  
  /// Service that provides account data
  private let accountService: AccountService
  
  // MARK: - Properties
  
  /// Cache of user accounts for faster access
  private var accountCache: [String: [Account]] = [:]
  
  // MARK: - Initialization
  
  /// Initializes a new account repository
  /// - Parameter accountService: Service that provides account data (defaults to mock implementation)
  init(accountService: AccountService = MockAccountService()) {
    self.accountService = accountService
  }
  
  // MARK: - Public Methods
  
  /// Fetches all accounts for a user
  /// - Parameter userId: The ID of the user
  /// - Returns: A publisher that emits an array of accounts or an error
  func getAccounts(for userId: String) -> AnyPublisher<[Account], Error> {
    // If we have cached accounts for this user, return them
    if let cachedAccounts = accountCache[userId] {
      return Just(cachedAccounts)
        .setFailureType(to: Error.self)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    // Otherwise fetch from the service and cache the result
    return accountService.getAccounts(for: userId)
      .handleEvents(receiveOutput: { [weak self] accounts in
        self?.accountCache[userId] = accounts
      })
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
  
  /// Fetches a specific account by ID
  /// - Parameter accountId: The ID of the account to fetch
  /// - Returns: A publisher that emits the account or an error
  func getAccount(by accountId: String) -> AnyPublisher<Account, Error> {
    // Check if we have this account in our cache
    for (_, accounts) in accountCache {
      if let account = accounts.first(where: { $0.id == accountId }) {
        return Just(account)
          .setFailureType(to: Error.self)
          .receive(on: DispatchQueue.main)
          .eraseToAnyPublisher()
      }
    }
    
    // If not found in cache, fetch from the service
    return accountService.getAccount(by: accountId)
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
  
  /// Clears the account cache
  func clearCache() {
    accountCache.removeAll()
  }
}