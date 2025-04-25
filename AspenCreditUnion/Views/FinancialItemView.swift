//
//  FinancialItemView.swift
//  AspenCreditUnion
//
//  Created on 4/25/25.
//

import SwiftUI

/// A component for displaying individual financial metrics with an icon
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
  HStack {
    FinancialItemView(
      title: "Assets", 
      value: 25000.00, 
      color: .green, 
      systemImage: "arrow.up.circle.fill"
    )
    
    FinancialItemView(
      title: "Debts", 
      value: 15000.00, 
      color: .red, 
      systemImage: "arrow.down.circle.fill"
    )
  }
  .padding()
  .previewLayout(.sizeThatFits)
}