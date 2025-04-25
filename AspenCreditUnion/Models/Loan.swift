import Foundation

/// A model representing a loan product
struct Loan: Identifiable, Codable {
  // MARK: - Properties
  
  /// Unique identifier for the loan
  let id: String
  /// Loan account number
  let accountNumber: String
  /// User-defined name of the loan
  let name: String
  /// Type of loan product
  let loanType: LoanType
  /// Original principal amount of the loan
  let originalPrincipal: Decimal
  /// Current outstanding principal balance
  let currentBalance: Decimal
  /// Annual interest rate (as a decimal, e.g. 0.0425 for 4.25%)
  let interestRate: Decimal
  /// Monthly payment amount
  let monthlyPayment: Decimal
  /// Date when the loan originated
  let originationDate: Date
  /// Date when the loan is scheduled to be paid off
  let maturityDate: Date
  /// Date when the next payment is due
  let nextPaymentDue: Date
  /// Amount due for the next payment
  let nextPaymentAmount: Decimal
  /// Owner's user ID
  let userId: String
  
  // MARK: - Computed Properties
  
  /// Percentage of the loan that has been paid off
  var payoffPercentage: Double {
    guard originalPrincipal > 0 else { return 0 }
    // Convert Decimal to Double using NSDecimalNumber as an intermediary
    let currentBalanceDouble = NSDecimalNumber(decimal: currentBalance).doubleValue
    let originalPrincipalDouble = NSDecimalNumber(decimal: originalPrincipal).doubleValue
    return (1 - (currentBalanceDouble / originalPrincipalDouble)) * 100
  }
  
  /// Number of remaining payments based on current payment schedule
  var remainingPayments: Int {
    guard let months = Calendar.current.dateComponents(
      [.month],
      from: Date(),
      to: maturityDate
    ).month else { return 0 }
    return max(0, months)
  }
}

/// Types of loan products
enum LoanType: String, Codable, CaseIterable {
  /// Home mortgage loan
  case mortgage
  /// Auto loan
  case auto
  /// Personal line of credit
  case personalLine
  /// Personal loan with fixed terms
  case personal
  /// Home equity line of credit
  case heloc
  /// Home equity loan
  case homeEquity
  /// Student loan
  case student
  
  /// User-friendly name of the loan type
  var displayName: String {
    switch self {
    case .mortgage:
      return "Mortgage"
    case .auto:
      return "Auto Loan"
    case .personalLine:
      return "Personal Line of Credit"
    case .personal:
      return "Personal Loan"
    case .heloc:
      return "Home Equity Line of Credit"
    case .homeEquity:
      return "Home Equity Loan"
    case .student:
      return "Student Loan"
    }
  }
  
  /// Determines if the loan type is a line of credit (revolving)
  var isLineOfCredit: Bool {
    switch self {
    case .personalLine, .heloc:
      return true
    default:
      return false
    }
  }
}
