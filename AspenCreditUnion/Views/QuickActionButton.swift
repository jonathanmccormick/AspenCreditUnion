//
//  QuickActionButton.swift
//  AspenCreditUnion
//
//  Created on 4/25/25.
//

import SwiftUI

/// A button for quick actions in the app
struct QuickActionButton: View {
  // MARK: - Properties
  
  let title: String
  let systemImage: String
  let action: () -> Void
  
  // MARK: - View Body
  
  var body: some View {
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
}

#Preview {
  HStack(spacing: 16) {
    QuickActionButton(title: "Transfer", systemImage: "arrow.left.arrow.right") {}
    QuickActionButton(title: "Pay Bill", systemImage: "dollarsign.circle") {}
    QuickActionButton(title: "More", systemImage: "ellipsis") {}
  }
  .padding()
}
