import Foundation

class AuthService {
    static let shared = AuthService()
    private let apiClient = APIClient.shared
    private let tokenManager = TokenManager.shared
    
    private init() {}
    
    // Register a new user
    func register(email: String, password: String, confirmPassword: String, firstName: String, lastName: String) async throws {
        let request = RegisterRequest(
            email: email,
            password: password,
            confirmPassword: confirmPassword,
            firstName: firstName,
            lastName: lastName
        )
        
        let _: EmptyResponse = try await apiClient.request(endpoint: .register, body: request)
    }
    
    // Login user
    func login(email: String, password: String) async throws -> Bool {
        let request = LoginRequest(email: email, password: password)
        let response: AuthResponse = try await apiClient.request(endpoint: .login, body: request)
        
        // Save tokens
        tokenManager.saveTokens(accessToken: response.token, refreshToken: response.refreshToken)
        return true
    }
    
    // Logout user
    func logout() async throws {
        let _: EmptyResponse = try await apiClient.request(endpoint: .logout)
        tokenManager.clearTokens()
    }
    
    // Get active sessions
    func getActiveSessions() async throws -> [ActiveSession] {
        return try await apiClient.request(endpoint: .activeSessions)
    }
    
    // Revoke a specific session
    func revokeSession(id: Int) async throws {
        let _: EmptyResponse = try await apiClient.request(endpoint: .revokeSession(id: id))
    }
    
    // Revoke all sessions
    func revokeAllSessions() async throws {
        let _: EmptyResponse = try await apiClient.request(endpoint: .revokeAllSessions)
        tokenManager.clearTokens()
    }
    
    // Check if user is authenticated
    var isAuthenticated: Bool {
        return tokenManager.accessToken != nil
    }
}