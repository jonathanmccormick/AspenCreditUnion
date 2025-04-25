//
//  AccountSummaryCard.swift
//  AspenCreditUnion
//
//  Created on 4/25/25.
//

import SwiftUI

/// A card showing account summary information
struct AccountSummaryCard: View {
  // MARK: - Properties
  
  let account: Account
  
  // MARK: - View Body
  
  var body: some View {
    VStack(spacing: 16) {
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text(account.accountType.displayName)
            .font(.subheadline)
            .foregroundStyle(.secondary)
          
          Text(account.name)
            .font(.title2)
            .fontWeight(.bold)
        }
        
        Spacer()
        
        AccountTypeIcon(accountType: account.accountType)
      }
      
      Divider()
      
      VStack(spacing: 12) {
        BalanceRow(title: "Current Balance", amount: account.balance, isPrimary: true)
        
        if account.hasPendingTransactions {
          BalanceRow(title: "Available Balance", amount: account.availableBalance, isPrimary: false)
          BalanceRow(title: "Pending", amount: account.pendingAmount, isPrimary: false)
        }
      }
      
      Divider()
      
      // Account details
      VStack(spacing: 12) {
        DetailRow(title: "Account Number", value: account.accountNumber)
        DetailRow(title: "Routing Number", value: account.routingNumber)
        DetailRow(title: "Opened", value: FormatUtils.formatDate(account.openedDate))
      }
    }
    .padding()
    .background(Color(.systemBackground))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    .padding(.horizontal)
  }
}

#Preview {
  AccountSummaryCard(
    account: Account(
      id: "acc123",
      accountNumber: "••••4567",
      routingNumber: "123456789",
      name: "Everyday Checking",
      accountType: .checking,
      balance: 1250.42,
      availableBalance: 1200.00,
      openedDate: Date(),
      userId: "user123"
    )
  )
}
