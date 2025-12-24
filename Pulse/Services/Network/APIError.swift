import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case network(Error)
    case decoding(Error)
    case authenticationRequired
    case server(statusCode: Int, message: String?)
    case unknown
    case noInternetConnection
    case serverUnavailable

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The requested URL is invalid."
        case .network(let error):
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain {
                switch nsError.code {
                case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
                    return "No internet connection. Please check your network settings."
                case NSURLErrorTimedOut:
                    return "Connection timed out. The server may be unavailable."
                case NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost:
                    return "Cannot connect to server. The server may be down."
                default:
                    return error.localizedDescription
                }
            }
            return error.localizedDescription
        case .decoding:
            return "Unable to decode server response."
        case .authenticationRequired:
            return "Please sign in to continue."
        case .server(let statusCode, let message):
            if let message, !message.isEmpty {
                return message
            }
            if statusCode >= 500 {
                return "Server error. Please try again later."
            }
            return "Server returned an error (code: \(statusCode))."
        case .noInternetConnection:
            return "No internet connection. Please check your network settings."
        case .serverUnavailable:
            return "Server is unavailable. Please try again later."
        case .unknown:
            return "An unknown error occurred."
        }
    }
    
    var isNetworkError: Bool {
        switch self {
        case .network(let error):
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain {
                return nsError.code == NSURLErrorNotConnectedToInternet ||
                       nsError.code == NSURLErrorNetworkConnectionLost ||
                       nsError.code == NSURLErrorTimedOut ||
                       nsError.code == NSURLErrorCannotFindHost ||
                       nsError.code == NSURLErrorCannotConnectToHost
            }
            return false
        case .noInternetConnection, .serverUnavailable:
            return true
        case .server(let statusCode, _):
            return statusCode >= 500
        default:
            return false
        }
    }
    
    var userFriendlyMessage: String {
        if isNetworkError {
            if case .network(let error) = self {
                let nsError = error as NSError
                if nsError.domain == NSURLErrorDomain {
                    switch nsError.code {
                    case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
                        return "No internet connection"
                    case NSURLErrorTimedOut, NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost:
                        return "Server is unavailable"
                    default:
                        break
                    }
                }
            }
            if case .server(let statusCode, _) = self, statusCode >= 500 {
                return "Server is unavailable"
            }
            return "No internet connection"
        }
        return errorDescription ?? "An error occurred"
    }
}

