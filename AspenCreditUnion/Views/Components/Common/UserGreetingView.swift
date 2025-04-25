//
//  UserGreetingView.swift
//  AspenCreditUnion
//
//  Created on 4/25/25.
//

import SwiftUI

/// A component for displaying user greeting and membership information
struct UserGreetingView: View {
  // MARK: - Properties
  
  let firstName: String
  let memberSince: Date
  
  // MARK: - View Body
  
  var body: some View {
    VStack(alignment: .leading) {
      Text("Hello, \(firstName)")
        .font(.title)
        .fontWeight(.bold)
      
      Text("Member since \(FormatUtils.formatDate(memberSince))")
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal)
  }
}

#Preview {
  UserGreetingView(
    firstName: "Jonathan", 
    memberSince: Date().addingTimeInterval(-365*24*60*60) // 1 year ago
  )
}
