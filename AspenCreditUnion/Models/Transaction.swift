import Foundation

/// A model representing a financial transaction
struct Transaction: Identifiable, Codable {
  // MARK: - Properties
  
  /// Unique identifier for the transaction
  let id: String
  /// Account ID where transaction occurred
  let accountId: String
  /// Date when the transaction took place
  let date: Date
  /// Transaction amount (positive for deposits, negative for withdrawals)
  let amount: Decimal
  /// Description of the transaction
  let description: String
  /// Merchant name if applicable
  let merchant: String?
  /// Category of the transaction
  let category: TransactionCategory
  /// Current processing status of the transaction
  let status: TransactionStatus
  /// Transaction type (e.g., debit, credit)
  let type: TransactionType
  
  // MARK: - Computed Properties
  
  /// Indicates whether the transaction is a deposit (money in)
  var isDeposit: Bool {
    amount > 0
  }
  
  /// Indicates whether the transaction is pending
  var isPending: Bool {
    status == .pending
  }
}

/// Categories for transactions
enum TransactionCategory: String, Codable, CaseIterable {
  case food
  case shopping
  case housing
  case transportation
  case utilities
  case healthcare
  case personal
  case entertainment
  case travel
  case education
  case income
  case transfer
  case payment
  case fee
  case other
  
  /// User-friendly display name for the category
  var displayName: String {
    switch self {
    case .food:
      return "Food & Dining"
    case .shopping:
      return "Shopping"
    case .housing:
      return "Housing"
    case .transportation:
      return "Transportation"
    case .utilities:
      return "Bills & Utilities"
    case .healthcare:
      return "Healthcare"
    case .personal:
      return "Personal"
    case .entertainment:
      return "Entertainment"
    case .travel:
      return "Travel"
    case .education:
      return "Education"
    case .income:
      return "Income"
    case .transfer:
      return "Transfer"
    case .payment:
      return "Payment"
    case .fee:
      return "Fee"
    case .other:
      return "Other"
    }
  }
}

/// Status of a transaction
enum TransactionStatus: String, Codable {
  /// Transaction has been posted to the account
  case completed
  /// Transaction is in progress but not yet finalized
  case pending
  /// Transaction has been canceled
  case canceled
}

/// Type of transaction
enum TransactionType: String, Codable {
  /// Money taken out of account (purchase, payment)
  case debit
  /// Money added to account (deposit, refund)
  case credit
  /// Money moved between accounts
  case transfer
  /// Withdrawal of cash
  case withdrawal
  /// Fee applied to account
  case fee
  /// Interest applied to account
  case interest
  /// Payment on a loan or bill
  case payment
}