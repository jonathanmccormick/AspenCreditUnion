//
//  AccountTypeIcon.swift
//  AspenCreditUnion
//
//  Created on 4/25/25.
//

import SwiftUI

/// Icon representing an account type
struct AccountTypeIcon: View {
  // MARK: - Properties
  
  let accountType: AccountType
  
  // MARK: - View Body
  
  var body: some View {
    ZStack {
      Circle()
        .fill(Color.blue.opacity(0.1))
        .frame(width: 40, height: 40)
      
      Image(systemName: iconName)
        .foregroundStyle(.blue)
    }
  }
  
  // MARK: - Computed Properties
  
  /// System icon name for the account type
  private var iconName: String {
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
  }
}

#Preview {
  HStack {
    ForEach(AccountType.allCases, id: \.self) { type in
      VStack {
        AccountTypeIcon(accountType: type)
        Text(type.displayName)
          .font(.caption)
      }
    }
  }
  .padding()
}
