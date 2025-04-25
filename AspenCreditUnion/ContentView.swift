//
//  ContentView.swift
//  AspenCreditUnion
//
//  Created by Jonathan McCormick on 4/24/25.
//

import SwiftUI

struct ContentView: View {
  // MARK: - Properties
  
  @StateObject private var viewModel = HomeViewModel()
  
  // MARK: - View Body
  
  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 24) {
          if let user = viewModel.user {
            // User greeting
            VStack(alignment: .leading) {
              Text("Hello, \(user.firstName)")
                .font(.title)
                .fontWeight(.bold)
              
              Text("Member since \(formattedDate(user.memberSince))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            
            // Financial summary
            VStack(spacing: 16) {
              financialSummaryCard
              
              // Accounts section
              accountsSection
              
              // Loans section
              loansSection
            }
          } else if viewModel.errorMessage != nil {
            // Error state
            VStack(spacing: 16) {
              Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 56))
                .foregroundStyle(.red)
              
              Text("Oops! Something went wrong")
                .font(.title2)
                .fontWeight(.bold)
              
              Text(viewModel.errorMessage ?? "Unknown error")
                .font(.body)
                .multilineTextAlignment(.center)
              
              Button("Try Again") {
                viewModel.refreshData()
              }
              .buttonStyle(.borderedProminent)
              .padding(.top, 8)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
          } else {
            // Loading state
            ProgressView()
              .frame(maxWidth: .infinity, maxHeight: 300)
          }
        }
        .padding(.vertical)
      }
      .navigationTitle("Aspen Credit Union")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            viewModel.refreshData()
          } label: {
            Image(systemName: "arrow.clockwise")
          }
        }
      }
      .refreshable {
        await Task { 
          viewModel.refreshData() 
        }.value
      }
    }
    .onAppear {
      // Load data when view appears
      viewModel.loadData()
    }
  }
  
  // MARK: - Subviews
  
  /// Financial summary card showing assets, debts and net worth
  private var financialSummaryCard: some View {
    VStack(spacing: 16) {
      Text("Financial Summary")
        .font(.headline)
        .frame(maxWidth: .infinity, alignment: .leading)
      
      HStack(spacing: 24) {
        financialItem(
          title: "Assets",
          value: viewModel.totalAccountBalance,
          color: .green,
          systemImage: "arrow.up.circle.fill"
        )
        
        financialItem(
          title: "Debts",
          value: viewModel.totalLoanBalance,
          color: .red,
          systemImage: "arrow.down.circle.fill"
        )
        
        financialItem(
          title: "Net Worth",
          value: viewModel.netWorth,
          color: viewModel.netWorth >= 0 ? .blue : .red,
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
  
  /// Section displaying user accounts
  private var accountsSection: some View {
    VStack(spacing: 12) {
      Text("My Accounts")
        .font(.headline)
        .frame(maxWidth: .infinity, alignment: .leading)
      
      if viewModel.accounts.isEmpty {
        Text("No accounts found")
          .foregroundStyle(.secondary)
          .frame(maxWidth: .infinity, alignment: .center)
          .padding(.vertical)
      } else {
        ForEach(viewModel.accounts) { account in
          NavigationLink(destination: AccountDetailsView(accountId: account.id)) {
            accountRow(account)
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
  
  /// Section displaying user loans
  private var loansSection: some View {
    VStack(spacing: 12) {
      Text("My Loans")
        .font(.headline)
        .frame(maxWidth: .infinity, alignment: .leading)
      
      if viewModel.loans.isEmpty {
        Text("No loans found")
          .foregroundStyle(.secondary)
          .frame(maxWidth: .infinity, alignment: .center)
          .padding(.vertical)
      } else {
        ForEach(viewModel.loans) { loan in
          NavigationLink(destination: LoanDetailsView(loanId: loan.id)) {
            loanRow(loan)
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
  
  /// Helper view for financial summary items
  private func financialItem(title: String, value: Decimal, color: Color, systemImage: String) -> some View {
    VStack(spacing: 4) {
      HStack(spacing: 4) {
        Image(systemName: systemImage)
          .foregroundStyle(color)
        
        Text(title)
          .font(.caption)
          .fontWeight(.medium)
      }
      
      Text(formatCurrency(value))
        .font(.subheadline)
        .fontWeight(.bold)
    }
    .frame(maxWidth: .infinity)
  }
  
  /// Account row item
  private func accountRow(_ account: Account) -> some View {
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
        Text(formatCurrency(account.balance))
          .font(.body)
          .fontWeight(.medium)
          
        if account.hasPendingTransactions {
          Text("\(formatCurrency(account.availableBalance)) available")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }
    }
    .padding(.vertical, 8)
  }
  
  /// Loan row item
  private func loanRow(_ loan: Loan) -> some View {
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
        Text(formatCurrency(loan.currentBalance))
          .font(.body)
          .fontWeight(.medium)
        
        Text("Next payment: \(formatCurrency(loan.nextPaymentAmount))")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }
    .padding(.vertical, 8)
  }
  
  // MARK: - Helper Methods
  
  /// Formats a date in a friendly readable format
  /// - Parameter date: Date to format
  /// - Returns: Formatted date string
  private func formattedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter.string(from: date)
  }
  
  /// Formats a decimal as a currency string
  /// - Parameter value: Decimal value to format
  /// - Returns: Currency-formatted string
  private func formatCurrency(_ value: Decimal) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    return formatter.string(from: value as NSDecimalNumber) ?? "$0.00"
  }
}

#Preview {
  ContentView()
}
