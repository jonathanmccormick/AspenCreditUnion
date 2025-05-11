import Foundation

enum Environment: String {
    case local
    case production
    
    var baseURL: URL {
        switch self {
        case .local:
            return URL(string: "http://localhost:5000")!
        case .production:
            // Replace with actual production URL when available
            return URL(string: "https://api.wessex-group.com")!
        }
    }
}

struct APIConfig {
    static let environment: Environment = {
//        #if DEBUG
//        return .local
//        #else
        return .production
//        #endif
    }()
    
    static var baseURL: URL {
        return environment.baseURL
    }
    
    static let apiVersion = "v1"
    static let apiPath = "/api/\(apiVersion)"
    
    static var fullBaseURL: URL {
        return baseURL.appendingPathComponent(apiPath)
    }
    
    // Default headers for all requests
    static var defaultHeaders: [String: String] {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
    
    // Timeout interval for requests in seconds
    static let timeoutInterval: TimeInterval = 30
}
