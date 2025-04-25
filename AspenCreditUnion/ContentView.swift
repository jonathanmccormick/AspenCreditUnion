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
            UserGreetingView(
              firstName: user.firstName,
              memberSince: user.memberSince
            )
            
            // Financial summary
            FinancialSummaryCard(
              assets: viewModel.totalAccountBalance,
              debts: viewModel.totalLoanBalance,
              netWorth: viewModel.netWorth
            )
            
            // Accounts section
            AccountListView(accounts: viewModel.accounts)
            
            // Loans section
            LoanListView(loans: viewModel.loans)
            
          } else {
            // Show loading or error state
            LoadingStateView(
              isLoading: viewModel.errorMessage == nil,
              errorMessage: viewModel.errorMessage,
              retryAction: viewModel.refreshData
            )
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
}

#Preview {
  ContentView()
}
