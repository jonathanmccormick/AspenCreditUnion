import SwiftUI
import Combine

/// View displaying detailed information about a bank account
struct AccountDetailsView: View {
  // MARK: - Properties
  
  @StateObject private var viewModel: AccountDetailsViewModel
  @State private var showingTransferSheet = false
  @State private var selectedTab = 0
  
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
          accountSummaryCard(account)
          
          // Quick actions
          quickActionsView
          
          // Transactions list with tab selector
          VStack(spacing: 4) {
            // Tab selector
            Picker("Transaction View", selection: $selectedTab) {
              Text("Recent").tag(0)
              Text("Pending").tag(1)
              Text("All").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            // Transactions based on selected tab
            switch selectedTab {
            case 0:
              transactionsList(viewModel.transactions.prefix(5))
            case 1:
              transactionsList(viewModel.transactions.filter { $0.isPending })
            case 2:
              transactionsList(viewModel.transactions)
            default:
              EmptyView()
            }
          }
          .padding(.top)
        }
        .padding(.vertical)
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
  
  // MARK: - Subviews
  
  /// Account summary card showing account details
  /// - Parameter account: Account to display
  /// - Returns: Account summary view
  private func accountSummaryCard(_ account: Account) -> some View {
    VStack(spacing: 16) {
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text(account.accountType.displayName)
            .font(.subheadline)
            .foregroundStyle(.secondary)
          
          Text(account.name)
            .font(.title2)
            .fontWeight(.bold)
        }
        
        Spacer()
        
        accountTypeIcon(account.accountType)
      }
      
      Divider()
      
      VStack(spacing: 12) {
        balanceRow(title: "Current Balance", amount: account.balance, isPrimary: true)
        
        if account.hasPendingTransactions {
          balanceRow(title: "Available Balance", amount: account.availableBalance, isPrimary: false)
          balanceRow(title: "Pending", amount: account.pendingAmount, isPrimary: false)
        }
      }
      
      Divider()
      
      // Account details
      VStack(spacing: 12) {
        detailRow(title: "Account Number", value: account.accountNumber)
        detailRow(title: "Routing Number", value: account.routingNumber)
        detailRow(title: "Opened", value: formattedDate(account.openedDate))
      }
    }
    .padding()
    .background(Color(.systemBackground))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    .padding(.horizontal)
  }
  
  /// Quick action buttons
  private var quickActionsView: some View {
    HStack(spacing: 16) {
      quickActionButton(
        title: "Transfer",
        systemImage: "arrow.left.arrow.right",
        action: { showingTransferSheet = true }
      )
      
      quickActionButton(
        title: "Pay Bill",
        systemImage: "dollarsign.circle",
        action: { /* Bill payment functionality */ }
      )
      
      quickActionButton(
        title: "More",
        systemImage: "ellipsis",
        action: { /* More actions */ }
      )
    }
    .padding(.horizontal)
  }
  
  /// Creates a quick action button
  /// - Parameters:
  ///   - title: Button title
  ///   - systemImage: SF Symbol name
  ///   - action: Action to perform when tapped
  /// - Returns: Quick action button view
  private func quickActionButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      VStack(spacing: 8) {
        Image(systemName: systemImage)
          .font(.system(size: 24))
          .foregroundStyle(.blue)
        
        Text(title)
          .font(.caption)
          .fontWeight(.medium)
      }
      .frame(maxWidth: .infinity)
      .padding()
      .background(Color(.systemGray6))
      .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    .buttonStyle(.plain)
  }
  
  /// Transactions list view
  /// - Parameter transactions: Transactions to display
  /// - Returns: Transactions list view
  private func transactionsList<T: RandomAccessCollection>(_ transactions: T) -> some View where T.Element == Transaction {
    VStack(spacing: 0) {
      if transactions.isEmpty {
        Text("No transactions found")
          .foregroundStyle(.secondary)
          .frame(maxWidth: .infinity, minHeight: 100)
          .background(Color(.systemBackground))
      } else {
        if let transactionsArray = transactions as? [Transaction], !transactionsArray.isEmpty {
          ForEach(transactionsArray) { transaction in
            transactionRow(transaction)
            
            if let lastTransaction = transactionsArray.last, transaction.id != lastTransaction.id {
              Divider()
                .padding(.horizontal)
            }
          }
          
          if selectedTab != 2 {
            Button {
              selectedTab = 2
              viewModel.loadAllTransactions()
            } label: {
              Text("View all transactions")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.blue)
                .padding()
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .background(Color(.systemBackground))
          }
        } else {
          Text("No transactions to display")
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(Color(.systemBackground))
        }
      }
    }
    .background(Color(.systemGray6))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .padding(.horizontal)
  }
  
  /// Transaction row item
  /// - Parameter transaction: Transaction to display
  /// - Returns: Transaction row view
  private func transactionRow(_ transaction: Transaction) -> some View {
    HStack {
      // Category icon
      Circle()
        .fill(categoryColor(transaction.category))
        .frame(width: 40, height: 40)
        .overlay {
          Image(systemName: categoryIcon(transaction.category))
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
        Text(formatCurrency(transaction.amount))
          .font(.body)
          .fontWeight(.medium)
          .foregroundStyle(transaction.amount >= 0 ? .green : .primary)
        
        Text(formattedDate(transaction.date))
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }
    .padding()
    .background(Color(.systemBackground))
  }
  
  /// Balance information row
  /// - Parameters:
  ///   - title: Row title
  ///   - amount: Monetary amount
  ///   - isPrimary: Whether this is the primary/main balance
  /// - Returns: Balance row view
  private func balanceRow(title: String, amount: Decimal, isPrimary: Bool) -> some View {
    HStack {
      Text(title)
        .font(isPrimary ? .headline : .subheadline)
      
      Spacer()
      
      Text(formatCurrency(amount))
        .font(isPrimary ? .title3 : .body)
        .fontWeight(isPrimary ? .bold : .medium)
    }
  }
  
  /// Detail information row
  /// - Parameters:
  ///   - title: Row title
  ///   - value: Detail value
  /// - Returns: Detail row view
  private func detailRow(title: String, value: String) -> some View {
    HStack {
      Text(title)
        .font(.subheadline)
        .foregroundStyle(.secondary)
      
      Spacer()
      
      Text(value)
        .font(.subheadline)
    }
  }
  
  /// Icon representing an account type
  /// - Parameter accountType: Type of account
  /// - Returns: Icon view
  private func accountTypeIcon(_ accountType: AccountType) -> some View {
    ZStack {
      Circle()
        .fill(Color.blue.opacity(0.1))
        .frame(width: 40, height: 40)
      
      Image(systemName: {
        switch accountType {
        case .checking:
          return "creditcard"
        case .savings:
          return "banknote"
        case .moneyMarket:
          return "chart.line.uptrend.xyaxis"
        case .certificateOfDeposit:
          return "lock.shield"
        }
      }())
      .foregroundStyle(.blue)
    }
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
  
  /// Returns an icon name for a transaction category
  /// - Parameter category: Transaction category
  /// - Returns: SF Symbol name
  private func categoryIcon(_ category: TransactionCategory) -> String {
    switch category {
    case .food:
      return "fork.knife"
    case .shopping:
      return "bag"
    case .housing:
      return "house"
    case .transportation:
      return "car"
    case .utilities:
      return "bolt"
    case .healthcare:
      return "cross.case"
    case .personal:
      return "person"
    case .entertainment:
      return "tv"
    case .travel:
      return "airplane"
    case .education:
      return "book"
    case .income:
      return "dollarsign"
    case .transfer:
      return "arrow.left.arrow.right"
    case .payment:
      return "creditcard"
    case .fee:
      return "exclamationmark.circle"
    case .other:
      return "ellipsis.circle"
    }
  }
  
  /// Returns a color for a transaction category
  /// - Parameter category: Transaction category
  /// - Returns: Color for the category
  private func categoryColor(_ category: TransactionCategory) -> Color {
    switch category {
    case .food:
      return .orange
    case .shopping:
      return .purple
    case .housing:
      return .blue
    case .transportation:
      return .green
    case .utilities:
      return .yellow
    case .healthcare:
      return .red
    case .personal:
      return .indigo
    case .entertainment:
      return .pink
    case .travel:
      return .mint
    case .education:
      return .teal
    case .income:
      return .green
    case .transfer:
      return .blue
    case .payment:
      return .red
    case .fee:
      return .orange
    case .other:
      return .gray
    }
  }
}

/// View for transferring money between accounts
struct TransferView: View {
  let fromAccountId: String
  let fromAccountName: String
  let balance: Decimal
  
  @Environment(\.dismiss) private var dismiss
  @State private var toAccountId: String = ""
  @State private var amount: String = ""
  @State private var description: String = "Transfer"
  
  var body: some View {
    NavigationStack {
      Form {
        Section("From") {
          Text(fromAccountName)
            .foregroundStyle(.secondary)
        }
        
        Section("To") {
          Text("Select an account")
            .foregroundStyle(.secondary)
          // In a real app, this would be a picker with other accounts
        }
        
        Section("Amount") {
          TextField("Amount", text: $amount)
            .keyboardType(.decimalPad)
        }
        
        Section("Description") {
          TextField("Description", text: $description)
        }
        
        Section {
          Button("Transfer") {
            // In a real app, this would call the viewModel's transfer method
            dismiss()
          }
          .frame(maxWidth: .infinity)
          .disabled(toAccountId.isEmpty || amount.isEmpty)
        }
      }
      .navigationTitle("Transfer Money")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            dismiss()
          }
        }
      }
    }
  }
}

#Preview {
  NavigationStack {
    AccountDetailsView(accountId: "acc_checking_123")
  }
}
