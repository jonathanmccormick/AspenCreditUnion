import Foundation
import Security

class TokenManager {
    static let shared = TokenManager()
    
    private let accessTokenKey = "com.aspencreditunion.accessToken"
    private let refreshTokenKey = "com.aspencreditunion.refreshToken"
    
    private(set) var accessToken: String? {
        get {
            return KeychainHelper.load(key: accessTokenKey)
        }
        set {
            if let newValue = newValue {
                KeychainHelper.save(key: accessTokenKey, data: newValue)
            } else {
                KeychainHelper.delete(key: accessTokenKey)
            }
        }
    }
    
    private(set) var refreshToken: String? {
        get {
            return KeychainHelper.load(key: refreshTokenKey)
        }
        set {
            if let newValue = newValue {
                KeychainHelper.save(key: refreshTokenKey, data: newValue)
            } else {
                KeychainHelper.delete(key: refreshTokenKey)
            }
        }
    }
    
    private init() {}
    
    func saveTokens(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
    
    func clearTokens() {
        self.accessToken = nil
        self.refreshToken = nil
    }
    
    func refreshAccessToken() async throws {
        guard let refreshToken = self.refreshToken else {
            throw APIError.unauthorized
        }
        
        // Create refresh token request
        struct RefreshTokenRequest: Encodable {
            let refreshToken: String
        }
        
        struct TokenResponse: Decodable {
            let token: String
            let refreshToken: String
        }
        
        let request = RefreshTokenRequest(refreshToken: refreshToken)
        let response: TokenResponse = try await APIClient.shared.request(endpoint: .refreshToken, body: request)
        
        // Save the new tokens
        saveTokens(accessToken: response.token, refreshToken: response.refreshToken)
    }
}

// Helper class for securely storing tokens in the Keychain
private class KeychainHelper {
    
    static func save(key: String, data: String) {
        if let data = data.data(using: .utf8) {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecValueData as String: data,
                kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
            ]
            
            SecItemDelete(query as CFDictionary)
            SecItemAdd(query as CFDictionary, nil)
        }
    }
    
    static func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess {
            if let data = dataTypeRef as? Data {
                return String(data: data, encoding: .utf8)
            }
        }
        
        return nil
    }
    
    static func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}