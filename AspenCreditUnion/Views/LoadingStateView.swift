//
//  LoadingStateView.swift
//  AspenCreditUnion
//
//  Created on 4/25/25.
//

import SwiftUI

/// A component for displaying loading and error states
struct LoadingStateView: View {
  // MARK: - Properties
  
  let isLoading: Bool
  let errorMessage: String?
  let retryAction: () -> Void
  
  // MARK: - View Body
  
  var body: some View {
    if isLoading {
      // Loading state
      ProgressView()
        .frame(maxWidth: .infinity, maxHeight: 300)
    } else if let errorMessage = errorMessage {
      // Error state
      VStack(spacing: 16) {
        Image(systemName: "exclamationmark.triangle")
          .font(.system(size: 56))
          .foregroundStyle(.red)
        
        Text("Oops! Something went wrong")
          .font(.title2)
          .fontWeight(.bold)
        
        Text(errorMessage)
          .font(.body)
          .multilineTextAlignment(.center)
        
        Button("Try Again") {
          retryAction()
        }
        .buttonStyle(.borderedProminent)
        .padding(.top, 8)
      }
      .padding()
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
  }
}

#Preview {
  VStack(spacing: 20) {
    LoadingStateView(
      isLoading: true,
      errorMessage: nil,
      retryAction: {}
    )
    .frame(height: 200)
    .background(Color.gray.opacity(0.1))
    
    LoadingStateView(
      isLoading: false,
      errorMessage: "Could not connect to the server. Please check your internet connection.",
      retryAction: {}
    )
    .frame(height: 300)
    .background(Color.gray.opacity(0.1))
  }
  .padding()
}
