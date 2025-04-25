import Foundation

/// A model representing a banking customer
struct User: Identifiable, Codable {
  // MARK: - Properties
  
  /// Unique identifier for the user
  let id: String
  /// User's first name
  let firstName: String
  /// User's last name
  let lastName: String
  /// User's email address
  let email: String
  /// User's phone number
  let phoneNumber: String
  /// User's physical address
  let address: Address
  /// Date when the user became a member
  let memberSince: Date
  
  // MARK: - Computed Properties
  
  /// User's full name (first + last)
  var fullName: String {
    "\(firstName) \(lastName)"
  }
}

/// A model representing a physical address
struct Address: Codable {
  /// Street address (line 1)
  let street: String
  /// Additional address info (apt, unit, etc.)
  let street2: String?
  /// City name
  let city: String
  /// State abbreviation (e.g., "CO")
  let state: String
  /// ZIP or postal code
  let zipCode: String
  
  /// Formatted multi-line address string
  var formattedAddress: String {
    var components = [street]
    
    if let street2 = street2, !street2.isEmpty {
      components.append(street2)
    }
    
    components.append("\(city), \(state) \(zipCode)")
    return components.joined(separator: "\n")
  }
}
