import Foundation
import Combine

/// Protocol defining loan data access operations
protocol LoanService {
  /// Fetches all loans for a user
  /// - Parameter userId: The ID of the user
  /// - Returns: A publisher that emits an array of loans or an error
  func getLoans(for userId: String) -> AnyPublisher<[Loan], Error>
  
  /// Fetches a specific loan by ID
  /// - Parameter loanId: The ID of the loan to fetch
  /// - Returns: A publisher that emits the loan or an error
  func getLoan(by loanId: String) -> AnyPublisher<Loan, Error>
  
  /// Makes a payment on a loan
  /// - Parameters:
  ///   - loanId: The ID of the loan
  ///   - amount: The payment amount
  ///   - fromAccountId: The account to withdraw the payment from
  /// - Returns: A publisher that emits the updated loan or an error
  func makePayment(loanId: String, amount: Decimal, fromAccountId: String) -> AnyPublisher<Loan, Error>
}

/// Mock implementation of LoanService that provides hardcoded data
class MockLoanService: LoanService {
  /// Collection of mock loans
  private var mockLoans = [
    Loan(
      id: "loan_mortgage_123",
      accountNumber: "****5432",
      name: "Home Mortgage",
      loanType: .mortgage,
      originalPrincipal: 350000.00,
      currentBalance: 290450.82,
      interestRate: 0.0425, // 4.25%
      monthlyPayment: 1720.32,
      originationDate: Calendar.current.date(from: DateComponents(year: 2018, month: 8, day: 15))!,
      maturityDate: Calendar.current.date(from: DateComponents(year: 2048, month: 8, day: 15))!,
      nextPaymentDue: Calendar.current.date(byAdding: .day, value: 10, to: Date())!,
      nextPaymentAmount: 1720.32,
      userId: "usr_12345"
    ),
    Loan(
      id: "loan_auto_456",
      accountNumber: "****7654",
      name: "Car Loan",
      loanType: .auto,
      originalPrincipal: 28000.00,
      currentBalance: 14230.56,
      interestRate: 0.0349, // 3.49%
      monthlyPayment: 510.25,
      originationDate: Calendar.current.date(from: DateComponents(year: 2020, month: 3, day: 10))!,
      maturityDate: Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 10))!,
      nextPaymentDue: Calendar.current.date(byAdding: .day, value: 5, to: Date())!,
      nextPaymentAmount: 510.25,
      userId: "usr_12345"
    ),
    Loan(
      id: "loan_ploc_789",
      accountNumber: "****9876",
      name: "Personal Line of Credit",
      loanType: .personalLine,
      originalPrincipal: 15000.00,
      currentBalance: 4250.00,
      interestRate: 0.0799, // 7.99%
      monthlyPayment: 125.00,
      originationDate: Calendar.current.date(from: DateComponents(year: 2021, month: 1, day: 15))!,
      maturityDate: Calendar.current.date(from: DateComponents(year: 2031, month: 1, day: 15))!,
      nextPaymentDue: Calendar.current.date(byAdding: .day, value: 15, to: Date())!,
      nextPaymentAmount: 125.00,
      userId: "usr_12345"
    )
  ]
  
  /// Simulates fetching user loans from a database/API
  /// - Parameter userId: User ID to fetch loans for
  /// - Returns: A publisher with matching loans
  func getLoans(for userId: String) -> AnyPublisher<[Loan], Error> {
    let filteredLoans = mockLoans.filter { $0.userId == userId }
    return Just(filteredLoans)
      .setFailureType(to: Error.self)
      .eraseToAnyPublisher()
  }
  
  /// Simulates fetching a specific loan by ID
  /// - Parameter loanId: Loan ID to fetch
  /// - Returns: A publisher with the matching loan or error
  func getLoan(by loanId: String) -> AnyPublisher<Loan, Error> {
    guard let loan = mockLoans.first(where: { $0.id == loanId }) else {
      return Fail(error: NSError(domain: "LoanService", code: 404, userInfo: nil))
        .eraseToAnyPublisher()
    }
    
    return Just(loan)
      .setFailureType(to: Error.self)
      .eraseToAnyPublisher()
  }
  
  /// Simulates making a payment on a loan
  /// - Parameters:
  ///   - loanId: The loan ID to make payment on
  ///   - amount: Payment amount
  ///   - fromAccountId: Account to withdraw from
  /// - Returns: A publisher with the updated loan
  func makePayment(loanId: String, amount: Decimal, fromAccountId: String) -> AnyPublisher<Loan, Error> {
    guard let index = mockLoans.firstIndex(where: { $0.id == loanId }) else {
      return Fail(error: NSError(domain: "LoanService", code: 404, userInfo: nil))
        .eraseToAnyPublisher()
    }
    
    // In a real implementation, we'd validate the account has funds, etc.
    // Here, we just update the loan balance
    var updatedLoan = mockLoans[index]
    let newBalance = updatedLoan.currentBalance - amount
    
    // Create an updated loan with the new balance
    updatedLoan = Loan(
      id: updatedLoan.id,
      accountNumber: updatedLoan.accountNumber,
      name: updatedLoan.name,
      loanType: updatedLoan.loanType,
      originalPrincipal: updatedLoan.originalPrincipal,
      currentBalance: newBalance,
      interestRate: updatedLoan.interestRate,
      monthlyPayment: updatedLoan.monthlyPayment,
      originationDate: updatedLoan.originationDate,
      maturityDate: updatedLoan.maturityDate,
      nextPaymentDue: Calendar.current.date(byAdding: .month, value: 1, to: updatedLoan.nextPaymentDue)!,
      nextPaymentAmount: updatedLoan.nextPaymentAmount,
      userId: updatedLoan.userId
    )
    
    // Update the loan in our mock database
    mockLoans[index] = updatedLoan
    
    return Just(updatedLoan)
      .setFailureType(to: Error.self)
      .eraseToAnyPublisher()
  }
}