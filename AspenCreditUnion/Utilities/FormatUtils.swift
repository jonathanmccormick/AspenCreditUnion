//
//  FormatUtils.swift
//  AspenCreditUnion
//
//  Created on 4/25/25.
//

import Foundation

/// Utility functions for common formatting operations
enum FormatUtils {
  /// Formats a date in a friendly readable format
  /// - Parameter date: Date to format
  /// - Returns: Formatted date string
  static func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter.string(from: date)
  }
  
  /// Formats a decimal as a currency string
  /// - Parameter value: Decimal value to format
  /// - Returns: Currency-formatted string
  static func formatCurrency(_ value: Decimal) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    return formatter.string(from: value as NSDecimalNumber) ?? "$0.00"
  }
}
