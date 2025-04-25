import Foundation

/// A model representing a bank account
struct Account: Identifiable, Codable {
  // MARK: - Properties
  
  /// Unique identifier for the account
  let id: String
  /// Account number (masked except for last 4 digits)
  let accountNumber: String
  /// Routing number for ACH transfers
  let routingNumber: String
  /// Name given to the account by the user
  let name: String
  /// Type of bank account
  let accountType: AccountType
  /// Current balance in the account
  let balance: Decimal
  /// Amount available for immediate withdrawal
  let availableBalance: Decimal
  /// Date when the account was opened
  let openedDate: Date
  /// Owner's user ID
  let userId: String
  
  // MARK: - Computed Properties
  
  /// Indicates whether the account has pending transactions
  var hasPendingTransactions: Bool {
    balance != availableBalance
  }
  
  /// Amount currently pending in the account
  var pendingAmount: Decimal {
    balance - availableBalance
  }
}

/// Types of bank accounts
enum AccountType: String, Codable, CaseIterable {
  /// Standard checking account
  case checking
  /// Standard savings account
  case savings
  /// Money market account with higher interest
  case moneyMarket
  /// Certificate of deposit
  case certificateOfDeposit
  
  /// User-friendly name of the account type
  var displayName: String {
    switch self {
    case .checking:
      return "Checking"
    case .savings:
      return "Savings"
    case .moneyMarket:
      return "Money Market"
    case .certificateOfDeposit:
      return "Certificate of Deposit"
    }
  }
}