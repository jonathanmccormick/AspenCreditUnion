import Foundation
import Combine

/// Repository that manages access to user data
class UserRepository {
  // MARK: - Dependencies
  
  /// Service that provides user data
  private let userService: UserService
  
  // MARK: - Initialization
  
  /// Initializes a new user repository
  /// - Parameter userService: Service that provides user data (defaults to mock implementation)
  init(userService: UserService = MockUserService()) {
    self.userService = userService
  }
  
  // MARK: - Public Methods
  
  /// Fetches the current authenticated user
  /// - Returns: A publisher that emits the current user or an error
  func getCurrentUser() -> AnyPublisher<User, Error> {
    return userService.getCurrentUser()
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
  
  /// Updates user profile information
  /// - Parameter user: Updated user information
  /// - Returns: A publisher that emits the updated user or an error
  func updateUserProfile(user: User) -> AnyPublisher<User, Error> {
    return userService.updateUserProfile(user: user)
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
}