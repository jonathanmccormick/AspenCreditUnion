import Foundation

class AccountService {
    static let shared = AccountService()
    private let apiClient = APIClient.shared
    
    private init() {}
    
    // Get all accounts for the authenticated user
    func getAllAccounts() async throws -> [Account] {
        return try await apiClient.request(endpoint: .getAllAccounts)
    }
    
    // Get available account types
    func getAccountTypes() async throws -> [AccountTypeInfo] {
        return try await apiClient.request(endpoint: .getAccountTypes)
    }
    
    // Get specific account by ID
    func getAccount(id: Int) async throws -> Account {
        return try await apiClient.request(endpoint: .getAccount(id: id))
    }
    
    // Create a new checking account
    func createCheckingAccount(initialDeposit: Decimal) async throws -> Account {
        let request = CheckingAccountRequest(initialDeposit: initialDeposit)
        return try await apiClient.request(endpoint: .createCheckingAccount, body: request)
    }
    
    // Create a new savings account
    func createSavingsAccount(initialDeposit: Decimal, interestRate: Decimal) async throws -> Account {
        let request = SavingsAccountRequest(
            initialDeposit: initialDeposit,
            interestRate: interestRate
        )
        return try await apiClient.request(endpoint: .createSavingsAccount, body: request)
    }
    
    // Create a new certificate of deposit account
    func createCDAccount(initialDeposit: Decimal, interestRate: Decimal, maturityDate: Date, autoRenew: Bool) async throws -> Account {
        let request = CDAccountRequest(
            initialDeposit: initialDeposit,
            interestRate: interestRate,
            maturityDate: maturityDate,
            autoRenew: autoRenew
        )
        return try await apiClient.request(endpoint: .createCDAccount, body: request)
    }
    
    // Create a new money market account
    func createMoneyMarketAccount(initialDeposit: Decimal, interestRate: Decimal) async throws -> Account {
        let request = MoneyMarketAccountRequest(
            initialDeposit: initialDeposit,
            interestRate: interestRate
        )
        return try await apiClient.request(endpoint: .createMoneyMarketAccount, body: request)
    }
}