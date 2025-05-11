import Foundation

// MARK: - Transaction Models

enum TransactionType: Int, Codable {
    case transfer = 0
    case loanPayment = 1
    case loanAdvance = 2
}

struct Transaction: Identifiable, Decodable {
    let id: String
    let type: TransactionType
    let amount: Decimal
    let description: String?
    let sourceAccountId: String
    let sourceAccountName: String
    let destinationAccountId: String
    let destinationAccountName: String
    let status: TransactionStatus
    let createdAt: Date
    let updatedAt: Date
}

enum TransactionStatus: String, Codable {
    case pending = "Pending"
    case completed = "Completed"
    case failed = "Failed"
    case canceled = "Canceled"
}

// MARK: - Transaction Requests

struct TransactionRequest: Encodable {
    let type: TransactionType
    let sourceAccountId: String
    let destinationAccountId: String
    let amount: Decimal
    let description: String?
}