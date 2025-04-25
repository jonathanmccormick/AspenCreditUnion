//
//  DetailRow.swift
//  AspenCreditUnion
//
//  Created on 4/25/25.
//

import SwiftUI

/// A row displaying label and detail information
struct DetailRow: View {
  // MARK: - Properties
  
  let title: String
  let value: String
  
  // MARK: - View Body
  
  var body: some View {
    HStack {
      Text(title)
        .font(.subheadline)
        .foregroundStyle(.secondary)
      
      Spacer()
      
      Text(value)
        .font(.subheadline)
    }
  }
}

#Preview {
  VStack(spacing: 8) {
    DetailRow(title: "Account Number", value: "••••4567")
    DetailRow(title: "Routing Number", value: "123456789")
    DetailRow(title: "Opened", value: "Apr 25, 2024")
  }
  .padding()
}
