//
//  LoanListView.swift
//  AspenCreditUnion
//
//  Created on 4/25/25.
//

import SwiftUI

/// A component for displaying a list of loans
struct LoanListView: View {
  // MARK: - Properties
  
  let loans: [Loan]
  let title: String
  let emptyMessage: String
  
  /// Default initializer with customization options
  /// - Parameters:
  ///   - loans: Array of loans to display
  ///   - title: Title for the section (default: "My Loans")
  ///   - emptyMessage: Message to display when no loans (default: "No loans found")
  init(
    loans: [Loan],
    title: String = "My Loans",
    emptyMessage: String = "No loans found"
  ) {
    self.loans = loans
    self.title = title
    self.emptyMessage = emptyMessage
  }
  
  // MARK: - View Body
  
  var body: some View {
    VStack(spacing: 12) {
      Text(title)
        .font(.headline)
        .frame(maxWidth: .infinity, alignment: .leading)
      
      if loans.isEmpty {
        Text(emptyMessage)
          .foregroundStyle(.secondary)
          .frame(maxWidth: .infinity, alignment: .center)
          .padding(.vertical)
      } else {
        ForEach(loans) { loan in
          NavigationLink(destination: LoanDetailsView(loanId: loan.id)) {
            LoanRow(loan: loan)
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
    LoanListView(
      loans: [
        Loan(
          id: "loan1",
          accountNumber: "••••1234",
          name: "Home Loan",
          loanType: .mortgage,
          originalPrincipal: 300000.00,
          currentBalance: 250000.00,
          interestRate: 0.0425,
          monthlyPayment: 1250.00,
          originationDate: Date().addingTimeInterval(-365*24*60*60),
          maturityDate: Date().addingTimeInterval(29*365*24*60*60),
          nextPaymentDue: Date().addingTimeInterval(30*24*60*60),
          nextPaymentAmount: 1250.00,
          userId: "user123"
        ),
        Loan(
          id: "loan2",
          accountNumber: "••••5678",
          name: "Car Loan",
          loanType: .auto,
          originalPrincipal: 25000.00,
          currentBalance: 15000.00,
          interestRate: 0.0399,
          monthlyPayment: 450.00,
          originationDate: Date().addingTimeInterval(-365*24*60*60),
          maturityDate: Date().addingTimeInterval(4*365*24*60*60),
          nextPaymentDue: Date().addingTimeInterval(15*24*60*60),
          nextPaymentAmount: 450.00,
          userId: "user123"
        )
      ]
    )
  }
}
