import Foundation

// MARK: - Account Models

enum AccountType: String, Codable {
    case checking = "Checking"
    case savings = "Savings"
    case cd = "CD"
    case moneyMarket = "MoneyMarket"
}

struct Account: Identifiable, Decodable {
    let id: String
    let accountNumber: String
    let type: AccountType
    let balance: Decimal
    let availableBalance: Decimal
    let name: String
    let createdAt: Date
    let updatedAt: Date
    
    // Additional properties based on account type
    let interestRate: Decimal?
    let maturityDate: Date?
    let autoRenew: Bool?
}

// Renamed from AccountType to AccountTypeInfo to avoid naming conflict
struct AccountTypeInfo: Decodable, Identifiable {
    let id: String
    let name: String
    let description: String
    let minimumDeposit: Decimal
    let monthlyFee: Decimal?
    let features: [String]
}

// MARK: - Account Creation Requests

struct CheckingAccountRequest: Encodable {
    let initialDeposit: Decimal
}

struct SavingsAccountRequest: Encodable {
    let initialDeposit: Decimal
    let interestRate: Decimal
}

struct CDAccountRequest: Encodable {
    let initialDeposit: Decimal
    let interestRate: Decimal
    let maturityDate: Date
    let autoRenew: Bool
}

struct MoneyMarketAccountRequest: Encodable {
    let initialDeposit: Decimal
    let interestRate: Decimal
}