//
//  AccountRow.swift
//  AspenCreditUnion
//
//  Created on 4/25/25.
//

import SwiftUI

/// A reusable row component for displaying account information
struct AccountRow: View {
  // MARK: - Properties
  
  let account: Account
  
  // MARK: - View Body
  
  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        Text(account.name)
          .font(.body)
          .fontWeight(.medium)
        
        Text(account.accountType.displayName)
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      
      Spacer()
      
      VStack(alignment: .trailing, spacing: 4) {
        Text(FormatUtils.formatCurrency(account.balance))
          .font(.body)
          .fontWeight(.medium)
          
        if account.hasPendingTransactions {
          Text("\(FormatUtils.formatCurrency(account.availableBalance)) available")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }
    }
    .padding(.vertical, 8)
  }
}

#Preview {
  AccountRow(
    account: Account(
      id: "123", 
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
  .previewLayout(.sizeThatFits)
  .padding()
}
