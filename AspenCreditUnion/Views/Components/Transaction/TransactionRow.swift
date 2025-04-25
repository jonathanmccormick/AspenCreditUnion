//
//  TransactionRow.swift
//  AspenCreditUnion
//
//  Created on 4/25/25.
//

import SwiftUI

/// A row displaying transaction information
struct TransactionRow: View {
  // MARK: - Properties
  
  let transaction: Transaction
  
  // MARK: - View Body
  
  var body: some View {
    HStack {
      // Category icon
      Circle()
        .fill(TransactionCategoryUtils.color(for: transaction.category))
        .frame(width: 40, height: 40)
        .overlay {
          Image(systemName: TransactionCategoryUtils.icon(for: transaction.category))
            .foregroundStyle(.white)
        }
      
      VStack(alignment: .leading, spacing: 4) {
        Text(transaction.description)
          .font(.body)
          .fontWeight(.medium)
        
        HStack(spacing: 4) {
          if let merchant = transaction.merchant {
            Text(merchant)
              .font(.caption)
              .foregroundStyle(.secondary)
          }
          
          if transaction.isPending {
            Text("Pending")
              .font(.caption)
              .padding(.horizontal, 6)
              .padding(.vertical, 2)
              .background(Color(.systemGray5))
              .clipShape(Capsule())
          }
        }
      }
      
      Spacer()
      
      VStack(alignment: .trailing, spacing: 4) {
        Text(FormatUtils.formatCurrency(transaction.amount))
          .font(.body)
          .fontWeight(.medium)
          .foregroundStyle(transaction.amount >= 0 ? .green : .primary)
        
        Text(FormatUtils.formatDate(transaction.date))
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }
    .padding()
    .background(Color(.systemBackground))
  }
}

#Preview {
  TransactionRow(
    transaction: Transaction(
      id: "tx123",
      accountId: "acc123",
      date: Date(), amount: -45.67,
      description: "Coffee Shop",
      merchant: "Aspen Brews",
      category: .food,
      status: .pending,
      type: .debit
    )
  )
  .previewLayout(.sizeThatFits)
  .padding()
}
