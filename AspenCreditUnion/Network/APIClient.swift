import Foundation

enum APIError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
    case serverError(statusCode: Int, message: String?)
    case unauthorized
    case noData
    case custom(String)
    
    var errorDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .requestFailed(let error):
            return "Request failed: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from the server."
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let statusCode, let message):
            return "Server error \(statusCode): \(message ?? "No error message provided")"
        case .unauthorized:
            return "Unauthorized. Please login again."
        case .noData:
            return "No data received from the server."
        case .custom(let message):
            return message
        }
    }
}

class APIClient {
    static let shared = APIClient()
    
    private let session: URLSession
    private let tokenManager: TokenManager
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = APIConfig.timeoutInterval
        self.session = URLSession(configuration: configuration)
        self.tokenManager = TokenManager.shared
    }
    
    // Generic request method for all API calls
    func request<T: Decodable>(endpoint: APIEndpoint, body: Encodable? = nil) async throws -> T {
        // Create the request
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = endpoint.method
        
        // Add default headers
        for (key, value) in APIConfig.defaultHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Add authorization token if available and not a login/register request
        if endpoint != .login && endpoint != .register && endpoint != .refreshToken {
            if let token = tokenManager.accessToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            } else {
                throw APIError.unauthorized
            }
        }
        
        // Add body if provided
        if let body = body {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(body)
        }
        
        // Perform the request
        let (data, response) = try await session.data(for: request)
        
        // Check for HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        // Handle HTTP status codes
        switch httpResponse.statusCode {
        case 200...299:
            // Success - continue processing
            break
        case 401:
            // Unauthorized - try to refresh token if not already attempting to refresh
            if endpoint != .refreshToken {
                try await tokenManager.refreshAccessToken()
                // Retry the request after refreshing
//                return try await request(endpoint: endpoint, body: body)
                let (data, response) = try await session.data(for: request)
            } else {
                throw APIError.unauthorized
            }
        case 400...499:
            // Client error
            let errorMessage = try? JSONDecoder().decode(ErrorResponse.self, from: data).message
            throw APIError.serverError(statusCode: httpResponse.statusCode, message: errorMessage)
        case 500...599:
            // Server error
            let errorMessage = try? JSONDecoder().decode(ErrorResponse.self, from: data).message
            throw APIError.serverError(statusCode: httpResponse.statusCode, message: errorMessage)
        default:
            throw APIError.serverError(statusCode: httpResponse.statusCode, message: "Unexpected status code")
        }
        
        // No data
        guard !data.isEmpty else {
            if T.self == EmptyResponse.self {
                return EmptyResponse() as! T
            }
            throw APIError.noData
        }
        
        // Decode the response
        do {
            let decoder = JSONDecoder()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSX"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)

            decoder.dateDecodingStrategy = .formatted(formatter)
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Failed to decode response")
            print(T.self)
            
            throw APIError.decodingFailed(error)
        }
    }
}

// Empty response for endpoints that don't return data
struct EmptyResponse: Decodable {}

// Standard error response
struct ErrorResponse: Decodable {
    let message: String
}
