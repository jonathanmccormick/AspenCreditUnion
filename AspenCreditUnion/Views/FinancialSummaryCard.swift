//
//  FinancialSummaryCard.swift
//  AspenCreditUnion
//
//  Created on 4/25/25.
//

import SwiftUI

/// A card showing financial summary including assets, debts and net worth
struct FinancialSummaryCard: View {
  // MARK: - Properties
  
  let assets: Decimal
  let debts: Decimal
  let netWorth: Decimal
  
  // MARK: - View Body
  
  var body: some View {
    VStack(spacing: 16) {
      Text("Financial Summary")
        .font(.headline)
        .frame(maxWidth: .infinity, alignment: .leading)
      
      HStack(spacing: 24) {
        FinancialItemView(
          title: "Assets",
          value: assets,
          color: .green,
          systemImage: "arrow.up.circle.fill"
        )
        
        FinancialItemView(
          title: "Debts",
          value: debts,
          color: .red,
          systemImage: "arrow.down.circle.fill"
        )
        
        FinancialItemView(
          title: "Net Worth",
          value: netWorth,
          color: netWorth >= 0 ? .blue : .red,
          systemImage: "dollarsign.circle.fill"
        )
      }
    }
    .padding()
    .background(Color(.systemBackground))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    .padding(.horizontal)
  }
}

/// A component for displaying financial metrics
struct FinancialItemView: View {
  // MARK: - Properties
  
  let title: String
  let value: Decimal
  let color: Color
  let systemImage: String
  
  // MARK: - View Body
  
  var body: some View {
    VStack(spacing: 4) {
      HStack(spacing: 4) {
        Image(systemName: systemImage)
          .foregroundStyle(color)
        
        Text(title)
          .font(.caption)
          .fontWeight(.medium)
      }
      
      Text(FormatUtils.formatCurrency(value))
        .font(.subheadline)
        .fontWeight(.bold)
    }
    .frame(maxWidth: .infinity)
  }
}

#Preview {
  FinancialSummaryCard(
    assets: 25000.00,
    debts: 15000.00,
    netWorth: 10000.00
  )
  .previewLayout(.sizeThatFits)
}
