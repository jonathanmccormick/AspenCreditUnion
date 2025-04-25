//
//  TransactionCategoryUtils.swift
//  AspenCreditUnion
//
//  Created on 4/25/25.
//

import SwiftUI

/// Utility functions for working with transaction categories
enum TransactionCategoryUtils {
  /// Returns an icon name for a transaction category
  /// - Parameter category: Transaction category
  /// - Returns: SF Symbol name
  static func icon(for category: TransactionCategory) -> String {
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
  static func color(for category: TransactionCategory) -> Color {
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
