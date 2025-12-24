import Foundation
import Combine

@MainActor
class ErrorHandler: ObservableObject {
    static let shared = ErrorHandler()
    
    @Published var currentError: APIError?
    @Published var shouldShowNetworkError = false
    
    private init() {}
    
    func handleError(_ error: Error) {
        if let apiError = error as? APIError {
            if apiError.isNetworkError {
                currentError = apiError
                shouldShowNetworkError = true
            }
        } else {
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain {
                let apiError: APIError
                switch nsError.code {
                case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
                    apiError = .noInternetConnection
                case NSURLErrorTimedOut, NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost:
                    apiError = .serverUnavailable
                default:
                    apiError = .network(error)
                }
                currentError = apiError
                shouldShowNetworkError = true
            }
        }
    }
    
    func clearError() {
        currentError = nil
        shouldShowNetworkError = false
    }
}

