import Foundation

class LoanService {
    static let shared = LoanService()
    private let apiClient = APIClient.shared
    
    private init() {}
    
    // Apply for a mortgage loan
    func applyForMortgage(principal: Decimal, interestRate: Decimal, loanTermYears: Int, propertyAddress: String) async throws -> Loan {
        let request = MortgageLoanRequest(
            principal: principal,
            interestRate: interestRate,
            loanTermYears: loanTermYears,
            propertyAddress: propertyAddress
        )
        return try await apiClient.request(endpoint: .applyForMortgage, body: request)
    }
    
    // Apply for an auto loan
    func applyForAutoLoan(principal: Decimal, interestRate: Decimal, loanTermMonths: Int, vehicleVIN: String) async throws -> Loan {
        let request = AutoLoanRequest(
            principal: principal,
            interestRate: interestRate,
            loanTermMonths: loanTermMonths,
            vehicleVIN: vehicleVIN
        )
        return try await apiClient.request(endpoint: .applyForAutoLoan, body: request)
    }
    
    // Apply for a credit card
    func applyForCreditCard(interestRate: Decimal, creditLimit: Decimal, annualFee: Decimal, rewardProgram: String) async throws -> Loan {
        let request = CreditCardRequest(
            interestRate: interestRate,
            creditLimit: creditLimit,
            annualFee: annualFee,
            rewardProgram: rewardProgram
        )
        return try await apiClient.request(endpoint: .applyForCreditCard, body: request)
    }
    
    // Apply for a personal loan
    func applyForPersonalLoan(principal: Decimal, interestRate: Decimal, purpose: String, loanTermMonths: Int, isSecured: Bool) async throws -> Loan {
        let request = PersonalLoanRequest(
            principal: principal,
            interestRate: interestRate,
            purpose: purpose,
            loanTermMonths: loanTermMonths,
            isSecured: isSecured
        )
        return try await apiClient.request(endpoint: .applyForPersonalLoan, body: request)
    }
    
    // Apply for a home equity line of credit
    func applyForHELOC(interestRate: Decimal, propertyAddress: String, propertyValue: Decimal, creditLimit: Decimal, currentEquity: Decimal, drawPeriodMonths: Int) async throws -> Loan {
        let request = HELOCRequest(
            interestRate: interestRate,
            propertyAddress: propertyAddress,
            propertyValue: propertyValue,
            creditLimit: creditLimit,
            currentEquity: currentEquity,
            drawPeriodMonths: drawPeriodMonths
        )
        return try await apiClient.request(endpoint: .applyForHELOC, body: request)
    }
    
    // Apply for a personal line of credit
    func applyForPersonalLineOfCredit(interestRate: Decimal, creditLimit: Decimal, drawPeriodMonths: Int, isSecured: Bool) async throws -> Loan {
        let request = PersonalLineOfCreditRequest(
            interestRate: interestRate,
            creditLimit: creditLimit,
            drawPeriodMonths: drawPeriodMonths,
            isSecured: isSecured
        )
        return try await apiClient.request(endpoint: .applyForPersonalLineOfCredit, body: request)
    }
}