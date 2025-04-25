//
//  TransferView.swift
//  AspenCreditUnion
//
//  Created on 4/25/25.
//

import SwiftUI

/// View for transferring money between accounts
struct TransferView: View {
  // MARK: - Properties
  
  let fromAccountId: String
  let fromAccountName: String
  let balance: Decimal
  
  @Environment(\.dismiss) private var dismiss
  @State private var toAccountId: String = ""
  @State private var amount: String = ""
  @State private var description: String = "Transfer"
  
  // MARK: - View Body
  
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
  TransferView(
    fromAccountId: "acc123",
    fromAccountName: "Everyday Checking",
    balance: 1250.42
  )
}
