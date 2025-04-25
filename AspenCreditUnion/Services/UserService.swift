import Foundation
import Combine

/// Protocol defining user data access operations
protocol UserService {
  /// Fetches the current authenticated user
  /// - Returns: A publisher that emits the current user or an error
  func getCurrentUser() -> AnyPublisher<User, Error>
  
  /// Updates user profile information
  /// - Parameter user: Updated user information
  /// - Returns: A publisher that emits the updated user or an error
  func updateUserProfile(user: User) -> AnyPublisher<User, Error>
}

/// Mock implementation of UserService that provides hardcoded data
class MockUserService: UserService {
  /// Mock user data
  private let mockUser = User(
    id: "usr_12345",
    firstName: "John",
    lastName: "Smith",
    email: "john.smith@example.com",
    phoneNumber: "(555) 123-4567",
    address: Address(
      street: "123 Main Street",
      street2: "Apt 4B",
      city: "Denver",
      state: "CO",
      zipCode: "80202"
    ),
    memberSince: Calendar.current.date(from: DateComponents(year: 2018, month: 6, day: 15))!
  )
  
  /// Provides mock user data
  /// - Returns: A publisher that emits the mock user data
  func getCurrentUser() -> AnyPublisher<User, Error> {
    Just(mockUser)
      .setFailureType(to: Error.self)
      .eraseToAnyPublisher()
  }
  
  /// Simulates updating user profile (returns the same user in this mock)
  /// - Parameter user: Updated user information
  /// - Returns: A publisher that emits the updated user
  func updateUserProfile(user: User) -> AnyPublisher<User, Error> {
    Just(user)
      .setFailureType(to: Error.self)
      .eraseToAnyPublisher()
  }
}
