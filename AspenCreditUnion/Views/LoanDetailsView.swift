import SwiftUI
import Combine

/// View displaying detailed information about a loan
struct LoanDetailsView: View {
  // MARK: - Properties
  
  @StateObject private var viewModel: LoanDetailsViewModel
  @State private var showingPaymentSheet = false
  @State private var selectedTab = 0
  
  // MARK: - Initialization
  
  /// Creates a new loan details view
  /// - Parameter loanId: The ID of the loan to display
  init(loanId: String) {
    _viewModel = StateObject(wrappedValue: LoanDetailsViewModel(loanId: loanId))
  }
  
  // MARK: - View Body
  
  var body: some View {
    ScrollView {
      if let loan = viewModel.loan {
        VStack(spacing: 20) {
          // Loan summary card
          loanSummaryCard(loan)
          
          // Payment progress
          paymentProgressView(loan)
          
          // Quick actions
          quickActionsView
          
          // Payment schedule and history
          VStack(spacing: 4) {
            // Tab selector
            Picker("Payment View", selection: $selectedTab) {
              Text("Next Payment").tag(0)
              Text("Payment History").tag(1)
              Text("Loan Details").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            // Content based on selected tab
            switch selectedTab {
            case 0:
              nextPaymentView(loan)
            case 1:
              paymentHistoryView
            case 2:
              loanDetailsView(loan)
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
    .navigationTitle(viewModel.loan?.name ?? "Loan Details")
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
    .sheet(isPresented: $showingPaymentSheet) {
      LoanPaymentView(
        loanId: viewModel.loan?.id ?? "",
        loanName: viewModel.loan?.name ?? "",
        paymentAmount: viewModel.loan?.nextPaymentAmount ?? 0
      )
    }
    .onAppear {
      // Load data when view appears
      viewModel.loadData()
    }
  }
  
  // MARK: - Subviews
  
  /// Loan summary card showing loan details
  /// - Parameter loan: Loan to display
  /// - Returns: Loan summary view
  private func loanSummaryCard(_ loan: Loan) -> some View {
    VStack(spacing: 16) {
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text(loan.loanType.displayName)
            .font(.subheadline)
            .foregroundStyle(.secondary)
          
          Text(loan.name)
            .font(.title2)
            .fontWeight(.bold)
        }
        
        Spacer()
        
        loanTypeIcon(loan.loanType)
      }
      
      Divider()
      
      VStack(spacing: 12) {
        balanceRow(title: "Current Balance", amount: loan.currentBalance, isPrimary: true)
        balanceRow(title: "Monthly Payment", amount: loan.monthlyPayment, isPrimary: false)
        balanceRow(title: "Interest Rate", amount: nil, formattedValue: viewModel.formattedInterestRate, isPrimary: false)
      }
    }
    .padding()
    .background(Color(.systemBackground))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    .padding(.horizontal)
  }
  
  /// Payment progress view
  /// - Parameter loan: Loan to display progress for
  /// - Returns: Progress view
  private func paymentProgressView(_ loan: Loan) -> some View {
    VStack(spacing: 12) {
      HStack {
        Text("Loan Payoff Progress")
          .font(.headline)
        
        Spacer()
        
        Text("\(Int(viewModel.percentagePaid))%")
          .font(.headline)
          .foregroundStyle(.blue)
      }
      
      ProgressView(value: viewModel.percentagePaid, total: 100)
        .tint(.blue)
        .frame(height: 8)
      
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text("Original Amount")
            .font(.caption)
            .foregroundStyle(.secondary)
          
          Text(formatCurrency(loan.originalPrincipal))
            .font(.subheadline)
        }
        
        Spacer()
        
        VStack(alignment: .trailing, spacing: 4) {
          Text("Total Paid")
            .font(.caption)
            .foregroundStyle(.secondary)
          
          Text(formatCurrency(viewModel.totalPaid))
            .font(.subheadline)
        }
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
        title: "Make Payment",
        systemImage: "dollarsign.circle.fill",
        action: { showingPaymentSheet = true }
      )
      
      quickActionButton(
        title: "Payment Schedule",
        systemImage: "calendar",
        action: { selectedTab = 0 }
      )
      
      quickActionButton(
        title: "Contact Us",
        systemImage: "phone",
        action: { /* Contact functionality */ }
      )
    }
    .padding(.horizontal)
  }
  
  /// Next payment details view
  /// - Parameter loan: Loan to display payment details for
  /// - Returns: Next payment view
  private func nextPaymentView(_ loan: Loan) -> some View {
    VStack(spacing: 16) {
      HStack(spacing: 20) {
        VStack(alignment: .center, spacing: 4) {
          Text("\(viewModel.daysUntilNextPayment ?? 0)")
            .font(.system(size: 36, weight: .bold))
            .foregroundStyle(.blue)
          
          Text("Days Until Due")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        
        VStack(alignment: .center, spacing: 4) {
          Text(formatCurrency(loan.nextPaymentAmount))
            .font(.system(size: 24, weight: .bold))
          
          Text("Payment Amount")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
      }
      .padding()
      
      VStack(spacing: 8) {
        Text("Due Date: \(formattedDate(loan.nextPaymentDue))")
          .font(.subheadline)
        
        Button("Make Payment Now") {
          showingPaymentSheet = true
        }
        .buttonStyle(.borderedProminent)
        .padding(.top)
      }
    }
    .padding()
    .background(Color(.systemBackground))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .padding(.horizontal)
  }
  
  /// Payment history list
  private var paymentHistoryView: some View {
    VStack(spacing: 0) {
      if viewModel.paymentHistory.isEmpty {
        Text("No payment history found")
          .foregroundStyle(.secondary)
          .frame(maxWidth: .infinity, minHeight: 100)
          .background(Color(.systemBackground))
      } else {
        ForEach(viewModel.paymentHistory) { payment in
          paymentRow(payment)
          
          if let lastPayment = viewModel.paymentHistory.last, payment.id != lastPayment.id {
            Divider()
              .padding(.horizontal)
          }
        }
      }
    }
    .background(Color(.systemGray6))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .padding(.horizontal)
  }
  
  /// Additional loan details
  /// - Parameter loan: Loan to display details for
  /// - Returns: Loan details view
  private func loanDetailsView(_ loan: Loan) -> some View {
    VStack(spacing: 16) {
      detailGroup(title: "Loan Information") {
        detailRow(title: "Account Number", value: loan.accountNumber)
        detailRow(title: "Loan Type", value: loan.loanType.displayName)
        detailRow(title: "Interest Rate", value: viewModel.formattedInterestRate)
      }
      
      detailGroup(title: "Important Dates") {
        detailRow(title: "Origination Date", value: formattedDate(loan.originationDate))
        detailRow(title: "Maturity Date", value: formattedDate(loan.maturityDate))
        detailRow(title: "Payments Remaining", value: "\(loan.remainingPayments)")
      }
      
      detailGroup(title: "Payment Information") {
        detailRow(title: "Original Principal", value: formatCurrency(loan.originalPrincipal))
        detailRow(title: "Current Balance", value: formatCurrency(loan.currentBalance))
        detailRow(title: "Monthly Payment", value: formatCurrency(loan.monthlyPayment))
      }
    }
    .padding()
    .background(Color(.systemBackground))
    .clipShape(RoundedRectangle(cornerRadius: 12))
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
  
  /// Payment row item
  /// - Parameter payment: Payment transaction to display
  /// - Returns: Payment row view
  private func paymentRow(_ payment: Transaction) -> some View {
    HStack {
      // Payment icon
      Circle()
        .fill(Color.green)
        .frame(width: 40, height: 40)
        .overlay {
          Image(systemName: "dollarsign.circle")
            .foregroundStyle(.white)
        }
      
      VStack(alignment: .leading, spacing: 4) {
        Text(payment.description)
          .font(.body)
          .fontWeight(.medium)
        
        Text(payment.status.rawValue.capitalized)
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      
      Spacer()
      
      VStack(alignment: .trailing, spacing: 4) {
        Text(formatCurrency(payment.amount.magnitude))
          .font(.body)
          .fontWeight(.medium)
        
        Text(formattedDate(payment.date))
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }
    .padding()
    .background(Color(.systemBackground))
  }
  
  /// Group of detail rows with a title
  /// - Parameters:
  ///   - title: Group title
  ///   - content: Detail row content
  /// - Returns: Detail group view
  private func detailGroup<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(title)
        .font(.headline)
        .padding(.bottom, 4)
      
      content()
    }
  }
  
  /// Balance information row
  /// - Parameters:
  ///   - title: Row title
  ///   - amount: Monetary amount (optional)
  ///   - formattedValue: Pre-formatted value string (optional)
  ///   - isPrimary: Whether this is the primary/main balance
  /// - Returns: Balance row view
  private func balanceRow(title: String, amount: Decimal?, formattedValue: String? = nil, isPrimary: Bool) -> some View {
    HStack {
      Text(title)
        .font(isPrimary ? .headline : .subheadline)
      
      Spacer()
      
      if let amount = amount {
        Text(formatCurrency(amount))
          .font(isPrimary ? .title3 : .body)
          .fontWeight(isPrimary ? .bold : .medium)
      } else if let formattedValue = formattedValue {
        Text(formattedValue)
          .font(isPrimary ? .title3 : .body)
          .fontWeight(isPrimary ? .bold : .medium)
      }
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
  
  /// Icon representing a loan type
  /// - Parameter loanType: Type of loan
  /// - Returns: Icon view
  private func loanTypeIcon(_ loanType: LoanType) -> some View {
    ZStack {
      Circle()
        .fill(Color.blue.opacity(0.1))
        .frame(width: 40, height: 40)
      
      Image(systemName: {
        switch loanType {
        case .mortgage, .homeEquity:
          return "house.fill"
        case .auto:
          return "car.fill"
        case .personalLine, .personal:
          return "person.text.rectangle.fill"
        case .heloc:
          return "house.and.flag.fill"
        case .student:
          return "books.vertical.fill"
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
}

/// View for making a loan payment
struct LoanPaymentView: View {
  let loanId: String
  let loanName: String
  let paymentAmount: Decimal
  
  @Environment(\.dismiss) private var dismiss
  @State private var fromAccountId: String = ""
  @State private var customAmount: Bool = false
  @State private var amount: String = ""
  @State private var availableAccounts: [Account] = []
  @State private var isLoading: Bool = false
  @State private var errorMessage: String?
  
  private var decimalAmount: Decimal? {
    Decimal(string: amount)
  }
  
  private var formattedPaymentAmount: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    return formatter.string(from: paymentAmount as NSDecimalNumber) ?? "$0.00"
  }
  
  var body: some View {
    NavigationStack {
      Form {
        Section("Payment Information") {
          Text(loanName)
            .font(.headline)
          
          if customAmount {
            TextField("Payment Amount", text: $amount)
              .keyboardType(.decimalPad)
          } else {
            HStack {
              Text("Scheduled Payment")
              Spacer()
              Text(formattedPaymentAmount)
                .foregroundStyle(.secondary)
            }
          }
          
          Toggle("Custom Amount", isOn: $customAmount)
        }
        
        Section("Payment From") {
          if availableAccounts.isEmpty {
            Text("Loading accounts...")
              .foregroundStyle(.secondary)
          } else {
            Picker("Select Account", selection: $fromAccountId) {
              ForEach(availableAccounts) { account in
                Text("\(account.name) (\(formatCurrency(account.availableBalance)))")
                  .tag(account.id)
              }
            }
          }
        }
        
        if let errorMessage = errorMessage {
          Section {
            Text(errorMessage)
              .foregroundStyle(.red)
          }
        }
        
        Section {
          Button(action: makePayment) {
            if isLoading {
              ProgressView()
                .frame(maxWidth: .infinity)
            } else {
              Text("Submit Payment")
                .frame(maxWidth: .infinity)
            }
          }
          .disabled(fromAccountId.isEmpty || (customAmount && (decimalAmount == nil || decimalAmount! <= 0)))
        }
      }
      .navigationTitle("Make Payment")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            dismiss()
          }
        }
      }
      .onAppear(perform: loadAccounts)
    }
  }
  
  private func loadAccounts() {
    isLoading = true
    
    // In a real app, this would call the viewModel to load accounts
    // For now, we'll just simulate with a delay
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      availableAccounts = [
        Account(
          id: "acc_checking_123",
          accountNumber: "****1234",
          routingNumber: "987654321",
          name: "Premium Checking",
          accountType: .checking,
          balance: 2534.67,
          availableBalance: 2489.67,
          openedDate: Date(),
          userId: "usr_12345"
        ),
        Account(
          id: "acc_savings_456",
          accountNumber: "****5678",
          routingNumber: "987654321",
          name: "High-Yield Savings",
          accountType: .savings,
          balance: 15780.42,
          availableBalance: 15780.42,
          openedDate: Date(),
          userId: "usr_12345"
        )
      ]
      
      // Set first account as default
      if !availableAccounts.isEmpty {
        fromAccountId = availableAccounts[0].id
      }
      
      isLoading = false
    }
  }
  
  private func makePayment() {
    isLoading = true
    errorMessage = nil
    
    // In a real app, this would call the viewModel's makePayment method
    // For now, we'll just simulate success with a delay
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
      isLoading = false
      dismiss()
    }
  }
  
  private func formatCurrency(_ value: Decimal) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    return formatter.string(from: value as NSDecimalNumber) ?? "$0.00"
  }
}

#Preview {
  NavigationStack {
    LoanDetailsView(loanId: "loan_mortgage_123")
  }
}