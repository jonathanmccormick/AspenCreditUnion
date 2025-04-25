//
//  AccountListView.swift
//  AspenCreditUnion
//
//  Created on 4/25/25.
//

import SwiftUI

/// A component for displaying a list of accounts
struct AccountListView: View {
  // MARK: - Properties
  
  let accounts: [Account]
  let title: String
  let emptyMessage: String
  
  /// Default initializer with customization options
  /// - Parameters:
  ///   - accounts: Array of accounts to display
  ///   - title: Title for the section (default: "My Accounts")
  ///   - emptyMessage: Message to display when no accounts (default: "No accounts found")
  init(
    accounts: [Account],
    title: String = "My Accounts",
    emptyMessage: String = "No accounts found"
  ) {
    self.accounts = accounts
    self.title = title
    self.emptyMessage = emptyMessage
  }
  
  // MARK: - View Body
  
  var body: some View {
    VStack(spacing: 12) {
      Text(title)
        .font(.headline)
        .frame(maxWidth: .infinity, alignment: .leading)
      
      if accounts.isEmpty {
        Text(emptyMessage)
          .foregroundStyle(.secondary)
          .frame(maxWidth: .infinity, alignment: .center)
          .padding(.vertical)
      } else {
        ForEach(accounts) { account in
          NavigationLink(destination: AccountDetailsView(accountId: account.id)) {
            AccountRow(account: account)
          }
          .buttonStyle(.plain)
        }
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
  NavigationStack {
    AccountListView(
      accounts: [
        Account(
          id: "acc1", 
          accountNumber: "••••1234", 
          routingNumber: "123456789", 
          name: "Everyday Checking", 
          accountType: .checking, 
          balance: 1250.42, 
          availableBalance: 1200.00, 
          openedDate: Date(), 
          userId: "user123"
        ),
        Account(
          id: "acc2", 
          accountNumber: "••••5678", 
          routingNumber: "123456789", 
          name: "Savings", 
          accountType: .savings, 
          balance: 5000.00, 
          availableBalance: 5000.00, 
          openedDate: Date(), 
          userId: "user123"
        )
      ]
    )
  }
}
