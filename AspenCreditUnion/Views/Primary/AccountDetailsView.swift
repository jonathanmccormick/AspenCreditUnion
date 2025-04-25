//
//  AccountDetailsView.swift
//  AspenCreditUnion
//
//  Created on 4/25/25.
//

import SwiftUI
import Combine

/// View displaying detailed information about a bank account
struct AccountDetailsView: View {
  // MARK: - Properties
  
  @StateObject private var viewModel: AccountDetailsViewModel
  @State private var showingTransferSheet = false
  
  // MARK: - Initialization
  
  /// Creates a new account details view
  /// - Parameter accountId: The ID of the account to display
  init(accountId: String) {
    _viewModel = StateObject(wrappedValue: AccountDetailsViewModel(accountId: accountId))
  }
  
  // MARK: - View Body
  
  var body: some View {
    ScrollView {
      if let account = viewModel.account {
        VStack(spacing: 20) {
          // Account summary card
          AccountSummaryCard(account: account)
          
          // Quick actions
          HStack(spacing: 16) {
            QuickActionButton(
              title: "Transfer",
              systemImage: "arrow.left.arrow.right",
              action: { showingTransferSheet = true }
            )
            
            QuickActionButton(
              title: "Pay Bill",
              systemImage: "dollarsign.circle",
              action: { /* Bill payment functionality */ }
            )
            
            QuickActionButton(
              title: "More",
              systemImage: "ellipsis",
              action: { /* More actions */ }
            )
          }
          .padding(.horizontal)
          
          // Transactions list with tab selector
          TransactionListView(
            transactions: viewModel.transactions,
            onViewAllTapped: {
              viewModel.loadAllTransactions()
            }
          )
        }
        .padding(.vertical)
      } else {
        // Show loading or error state
        LoadingStateView(
          isLoading: viewModel.errorMessage == nil,
          errorMessage: viewModel.errorMessage,
          retryAction: viewModel.refreshData
        )
      }
    }
    .navigationTitle(viewModel.account?.name ?? "Account Details")
    .navigationBarTitleDisplayMode(.large)
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
    .sheet(isPresented: $showingTransferSheet) {
      TransferView(
        fromAccountId: viewModel.account?.id ?? "",
        fromAccountName: viewModel.account?.name ?? "",
        balance: viewModel.account?.availableBalance ?? 0
      )
    }
    .onAppear {
      // Load data when view appears
      viewModel.loadData()
    }
  }
}

#Preview {
  NavigationStack {
    AccountDetailsView(accountId: "acc_checking_123")
  }
}
