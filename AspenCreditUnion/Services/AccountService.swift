import Foundation
import Combine

/// Protocol defining account data access operations
protocol AccountService {
  /// Fetches all accounts for a user
  /// - Parameter userId: The ID of the user
  /// - Returns: A publisher that emits an array of accounts or an error
  func getAccounts(for userId: String) -> AnyPublisher<[Account], Error>
  
  /// Fetches a specific account by ID
  /// - Parameter accountId: The ID of the account to fetch
  /// - Returns: A publisher that emits the account or an error
  func getAccount(by accountId: String) -> AnyPublisher<Account, Error>
}

/// Mock implementation of AccountService that provides hardcoded data
class MockAccountService: AccountService {
  /// Collection of mock accounts
  private let mockAccounts = [
    Account(
      id: "acc_checking_123",
      accountNumber: "****1234",
      routingNumber: "987654321",
      name: "Premium Checking",
      accountType: .checking,
      balance: 2534.67,
      availableBalance: 2489.67,
      openedDate: Calendar.current.date(from: DateComponents(year: 2018, month: 6, day: 15))!,
      userId: "usr_12345"
    ),
    Account(
      id: "acc_savings_456",
      accountNumber: "****5678",
      routingNumber: "987654321",
      name: "High-Yield Savings",
      accountType: .savings,
      balance: 15780.42,
      availableBalance: 15780.42,
      openedDate: Calendar.current.date(from: DateComponents(year: 2018, month: 7, day: 12))!,
      userId: "usr_12345"
    ),
    Account(
      id: "acc_mm_789",
      accountNumber: "****9012",
      routingNumber: "987654321",
      name: "Money Market",
      accountType: .moneyMarket,
      balance: 25000.00,
      availableBalance: 25000.00,
      openedDate: Calendar.current.date(from: DateComponents(year: 2020, month: 2, day: 8))!,
      userId: "usr_12345"
    )
  ]
  
  /// Simulates fetching user accounts from a database/API
  /// - Parameter userId: User ID to fetch accounts for
  /// - Returns: A publisher with matching accounts
  func getAccounts(for userId: String) -> AnyPublisher<[Account], Error> {
    let filteredAccounts = mockAccounts.filter { $0.userId == userId }
    return Just(filteredAccounts)
      .setFailureType(to: Error.self)
      .eraseToAnyPublisher()
  }
  
  /// Simulates fetching a specific account by ID
  /// - Parameter accountId: Account ID to fetch
  /// - Returns: A publisher with the matching account or error
  func getAccount(by accountId: String) -> AnyPublisher<Account, Error> {
    guard let account = mockAccounts.first(where: { $0.id == accountId }) else {
      return Fail(error: NSError(domain: "AccountService", code: 404, userInfo: nil))
        .eraseToAnyPublisher()
    }
    
    return Just(account)
      .setFailureType(to: Error.self)
      .eraseToAnyPublisher()
  }
}
