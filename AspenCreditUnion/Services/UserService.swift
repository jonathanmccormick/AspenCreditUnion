import Foundation

class UserService {
    static let shared = UserService()
    private let apiClient = APIClient.shared
    
    private init() {}
    
    // Get user profile
    func getProfile() async throws -> UserProfile {
        return try await apiClient.request(endpoint: .getProfile)
    }
    
    // Update user profile
    func updateProfile(firstName: String, lastName: String, phoneNumber: String?) async throws -> UserProfile {
        let request = UpdateProfileRequest(
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber
        )
        
        return try await apiClient.request(endpoint: .updateProfile, body: request)
    }
    
    // Change password
    func changePassword(currentPassword: String, newPassword: String, confirmPassword: String) async throws {
        let request = ChangePasswordRequest(
            currentPassword: currentPassword,
            newPassword: newPassword,
            confirmPassword: confirmPassword
        )
        
        let _: EmptyResponse = try await apiClient.request(endpoint: .changePassword, body: request)
    }
}