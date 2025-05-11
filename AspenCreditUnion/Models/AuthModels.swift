import Foundation

// MARK: - Authentication Models

struct RegisterRequest: Encodable {
    let email: String
    let password: String
    let confirmPassword: String
    let firstName: String
    let lastName: String
}

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct AuthResponse: Decodable {
    let token: String
    let refreshToken: String
    let expiresAt: Date
}

struct RefreshTokenRequest: Encodable {
    let refreshToken: String
}

struct ActiveSession: Decodable, Identifiable {
    let id: Int
    let deviceName: String
    let ipAddress: String
    let lastActive: Date
    let isCurrentSession: Bool
}

// MARK: - User Models

struct UserProfile: Decodable, Identifiable {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
    let phoneNumber: String?
    let createdAt: Date
    let updatedAt: Date
}

struct UpdateProfileRequest: Encodable {
    let firstName: String
    let lastName: String
    let phoneNumber: String?
}

struct ChangePasswordRequest: Encodable {
    let currentPassword: String
    let newPassword: String
    let confirmPassword: String
}