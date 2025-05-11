import Foundation

// MARK: - Loan Models

enum LoanType: String, Codable {
    case mortgage = "Mortgage"
    case auto = "Auto"
    case creditCard = "CreditCard"
    case personal = "Personal"
    case heloc = "HELOC"
    case personalLineOfCredit = "PersonalLineOfCredit"
}

struct Loan: Identifiable, Decodable {
    let id: String
    let accountNumber: String
    let type: LoanType
    let status: LoanStatus
    let balance: Decimal
    let availableCredit: Decimal?
    let interestRate: Decimal
    let paymentAmount: Decimal
    let nextPaymentDue: Date
    let createdAt: Date
    let updatedAt: Date
    
    // Specific loan properties
    let principal: Decimal?
    let maturityDate: Date?
    let loanTermMonths: Int?
    let creditLimit: Decimal?
    let drawPeriodMonths: Int?
    let propertyAddress: String?
    let propertyValue: Decimal?
    let vehicleVIN: String?
    let rewardProgram: String?
    let annualFee: Decimal?
    let isSecured: Bool?
}

enum LoanStatus: String, Codable {
    case pending = "Pending"
    case approved = "Approved"
    case active = "Active"
    case closed = "Closed"
    case delinquent = "Delinquent"
}

// MARK: - Loan Application Requests

struct MortgageLoanRequest: Encodable {
    let principal: Decimal
    let interestRate: Decimal
    let loanTermYears: Int
    let propertyAddress: String
}

struct AutoLoanRequest: Encodable {
    let principal: Decimal
    let interestRate: Decimal
    let loanTermMonths: Int
    let vehicleVIN: String
}

struct CreditCardRequest: Encodable {
    let interestRate: Decimal
    let creditLimit: Decimal
    let annualFee: Decimal
    let rewardProgram: String
}

struct PersonalLoanRequest: Encodable {
    let principal: Decimal
    let interestRate: Decimal
    let purpose: String
    let loanTermMonths: Int
    let isSecured: Bool
}

struct HELOCRequest: Encodable {
    let interestRate: Decimal
    let propertyAddress: String
    let propertyValue: Decimal
    let creditLimit: Decimal
    let currentEquity: Decimal
    let drawPeriodMonths: Int
}

struct PersonalLineOfCreditRequest: Encodable {
    let interestRate: Decimal
    let creditLimit: Decimal
    let drawPeriodMonths: Int
    let isSecured: Bool
}