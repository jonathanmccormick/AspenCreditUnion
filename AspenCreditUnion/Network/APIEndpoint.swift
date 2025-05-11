import Foundation

enum APIEndpoint: Equatable {
    // Authentication endpoints
    case register
    case login
    case refreshToken
    case logout
    case activeSessions
    case revokeSession(id: Int)
    case revokeAllSessions
    
    // User endpoints
    case getProfile
    case updateProfile
    case changePassword
    
    // Account endpoints
    case getAllAccounts
    case getAccountTypes
    case getAccount(id: Int)
    case createCheckingAccount
    case createSavingsAccount
    case createCDAccount
    case createMoneyMarketAccount
    
    // Loan endpoints
    case applyForMortgage
    case applyForAutoLoan
    case applyForCreditCard
    case applyForPersonalLoan
    case applyForHELOC
    case applyForPersonalLineOfCredit
    
    // Transaction endpoints
    case getTransactionHistory
    case createTransaction
    
    var path: String {
        switch self {
        // Authentication
        case .register: 
            return "/auth/register"
        case .login: 
            return "/auth/login"
        case .refreshToken: 
            return "/auth/refresh-token"
        case .logout: 
            return "/auth/logout"
        case .activeSessions: 
            return "/auth/active-sessions"
        case .revokeSession(let id): 
            return "/auth/revoke-session/\(id)"
        case .revokeAllSessions: 
            return "/auth/revoke-all-sessions"
            
        // User
        case .getProfile: 
            return "/user/profile"
        case .updateProfile: 
            return "/user/profile"
        case .changePassword: 
            return "/user/change-password"
            
        // Accounts
        case .getAllAccounts: 
            return "/accounts"
        case .getAccountTypes: 
            return "/accounts/types"
        case .getAccount(let id): 
            return "/accounts/\(id)"
        case .createCheckingAccount: 
            return "/accounts/checking"
        case .createSavingsAccount: 
            return "/accounts/savings"
        case .createCDAccount: 
            return "/accounts/cd"
        case .createMoneyMarketAccount: 
            return "/accounts/money-market"
            
        // Loans
        case .applyForMortgage: 
            return "/loans/mortgage"
        case .applyForAutoLoan: 
            return "/loans/auto"
        case .applyForCreditCard: 
            return "/loans/credit-card"
        case .applyForPersonalLoan: 
            return "/loans/personal"
        case .applyForHELOC: 
            return "/loans/heloc"
        case .applyForPersonalLineOfCredit: 
            return "/loans/personal-line-of-credit"
            
        // Transactions
        case .getTransactionHistory: 
            return "/transactions/history"
        case .createTransaction: 
            return "/transactions"
        }
    }
    
    var method: String {
        switch self {
        // GET methods
        case .getProfile, .getAllAccounts, .getAccountTypes, 
             .getAccount, .getTransactionHistory, .activeSessions:
            return "GET"
            
        // PUT methods
        case .updateProfile, .changePassword:
            return "PUT"
            
        // All other cases are POST
        default:
            return "POST"
        }
    }
    
    var url: URL {
        return APIConfig.fullBaseURL.appendingPathComponent(path)
    }
}
