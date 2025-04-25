//
//  LoanRow.swift
//  AspenCreditUnion
//
//  Created on 4/25/25.
//

import SwiftUI

/// A reusable row component for displaying loan information
struct LoanRow: View {
  // MARK: - Properties
  
  let loan: Loan
  
  // MARK: - View Body
  
  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        Text(loan.name)
          .font(.body)
          .fontWeight(.medium)
        
        Text(loan.loanType.displayName)
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      
      Spacer()
      
      VStack(alignment: .trailing, spacing: 4) {
        Text(FormatUtils.formatCurrency(loan.currentBalance))
          .font(.body)
          .fontWeight(.medium)
        
        Text("Next payment: \(FormatUtils.formatCurrency(loan.nextPaymentAmount))")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }
    .padding(.vertical, 8)
  }
}

#Preview {
  LoanRow(
    loan: Loan(
      id: "123",
      accountNumber: "••••4567",
      name: "Home Loan",
      loanType: .mortgage,
      originalPrincipal: 300000.00,
      currentBalance: 250000.00,
      interestRate: 0.0425,
      monthlyPayment: 1250.00,
      originationDate: Date().addingTimeInterval(-365*24*60*60), // 1 year ago
      maturityDate: Date().addingTimeInterval(29*365*24*60*60),  // 29 years from now
      nextPaymentDue: Date().addingTimeInterval(30*24*60*60),    // 30 days from now
      nextPaymentAmount: 1250.00,
      userId: "user123"
    )
  )
  .previewLayout(.sizeThatFits)
  .padding()
}
