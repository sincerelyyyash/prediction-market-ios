import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case network(Error)
    case decoding(Error)
    case authenticationRequired
    case server(statusCode: Int, message: String?)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The requested URL is invalid."
        case .network(let error):
            return error.localizedDescription
        case .decoding:
            return "Unable to decode server response."
        case .authenticationRequired:
            return "Please sign in to continue."
        case .server(let statusCode, let message):
            if let message, !message.isEmpty {
                return message
            }
            return "Server returned an error (code: \(statusCode))."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}

