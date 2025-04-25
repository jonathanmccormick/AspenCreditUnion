//
//  BalanceRow.swift
//  AspenCreditUnion
//
//  Created on 4/25/25.
//

import SwiftUI

/// A row displaying balance information
struct BalanceRow: View {
  // MARK: - Properties
  
  let title: String
  let amount: Decimal
  let isPrimary: Bool
  
  // MARK: - View Body
  
  var body: some View {
    HStack {
      Text(title)
        .font(isPrimary ? .headline : .subheadline)
      
      Spacer()
      
      Text(FormatUtils.formatCurrency(amount))
        .font(isPrimary ? .title3 : .body)
        .fontWeight(isPrimary ? .bold : .medium)
    }
  }
}

#Preview {
  VStack(spacing: 8) {
    BalanceRow(title: "Current Balance", amount: 1250.42, isPrimary: true)
    BalanceRow(title: "Available Balance", amount: 1200.00, isPrimary: false)
    BalanceRow(title: "Pending", amount: 50.42, isPrimary: false)
  }
  .padding()
}
