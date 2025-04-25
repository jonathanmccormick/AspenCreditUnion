//
//  TransactionListView.swift
//  AspenCreditUnion
//
//  Created on 4/25/25.
//

import SwiftUI

/// A view for displaying a list of transactions with tab filtering
struct TransactionListView: View {
  // MARK: - Properties
  
  let transactions: [Transaction]
  let onViewAllTapped: () -> Void
  
  @State private var selectedTab = 0
  
  // MARK: - View Body
  
  var body: some View {
    VStack(spacing: 4) {
      // Tab selector
      Picker("Transaction View", selection: $selectedTab) {
        Text("Recent").tag(0)
        Text("Pending").tag(1)
        Text("All").tag(2)
      }
      .pickerStyle(.segmented)
      .padding(.horizontal)
      
      // Transactions based on selected tab
      transactionsList()
    }
    .padding(.top)
  }
  
  // MARK: - Private Methods
  
  private func transactionsList() -> some View {
    VStack(spacing: 0) {
      let displayedTransactions: [Transaction] = {
        switch selectedTab {
        case 0:
          return Array(transactions.prefix(5))
        case 1:
          return transactions.filter { $0.isPending }
        case 2:
          return transactions
        default:
          return []
        }
      }()
      
      if displayedTransactions.isEmpty {
        Text("No transactions found")
          .foregroundStyle(.secondary)
          .frame(maxWidth: .infinity, minHeight: 100)
          .background(Color(.systemBackground))
      } else {
        ForEach(displayedTransactions) { transaction in
          TransactionRow(transaction: transaction)
          
          if transaction.id != displayedTransactions.last?.id {
            Divider()
              .padding(.horizontal)
          }
        }
        
        if selectedTab != 2 && transactions.count > 5 {
          Button {
            onViewAllTapped()
          } label: {
            Text("View all transactions")
              .font(.subheadline)
              .fontWeight(.medium)
              .foregroundStyle(.blue)
              .padding()
              .frame(maxWidth: .infinity)
          }
          .buttonStyle(.plain)
          .background(Color(.systemBackground))
        }
      }
    }
    .background(Color(.systemGray6))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .padding(.horizontal)
  }
}

#Preview {
  TransactionListView(
    transactions: [
      Transaction(
        id: "tx1",
        accountId: "acc123",
        date: Date(),
        amount: -45.67,
        description: "Coffee Shop",
        merchant: "Aspen Brews",
        category: .food,
        status: .pending,
        type: .debit
      ),
      Transaction(
        id: "tx2",
        accountId: "acc123",
        date: Date().addingTimeInterval(-86400),
        amount: -125.30,
        description: "Grocery Store",
        merchant: "Mountain Market",
        category: .shopping,
        status: .completed,
        type: .debit
      ),
      Transaction(
        id: "tx3",
        accountId: "acc123",
        date: Date().addingTimeInterval(-172800),
        amount: 1500.00,
        description: "Payroll Deposit",
        merchant: "ACME Corp",
        category: .income,
        status: .completed,
        type: .credit
      )
    ],
    onViewAllTapped: {}
  )
}
