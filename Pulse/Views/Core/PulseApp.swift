import SwiftUI

@main
struct PulseApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

private struct RootView: View {
    @StateObject private var authService = AuthService.shared
    @StateObject private var networkMonitor = NetworkMonitor.shared
    @StateObject private var errorHandler = ErrorHandler.shared
    @State private var showNetworkError = false
    @State private var networkErrorMessage = ""
    
    var body: some View {
        ZStack {
            if authService.isAuthenticated {
                ContentView()
                    .transition(.fadeTransition)
            } else {
                OnboardingView()
                    .transition(.fadeTransition)
            }
            
            if showNetworkError {
                NetworkErrorView(message: networkErrorMessage) {
                    showNetworkError = false
                    errorHandler.clearError()
                    Task {
                        await checkNetworkStatus()
                    }
                }
                .transition(.opacity)
                .zIndex(1000)
            }
        }
        .animation(.fadeTransition, value: authService.isAuthenticated)
        .onChange(of: networkMonitor.isConnected) { _, isConnected in
            if !isConnected {
                networkErrorMessage = "No internet connection"
                showNetworkError = true
            } else if showNetworkError && networkErrorMessage == "No internet connection" {
                showNetworkError = false
                errorHandler.clearError()
            }
        }
        .onChange(of: errorHandler.shouldShowNetworkError) { _, shouldShow in
            if shouldShow, let error = errorHandler.currentError {
                networkErrorMessage = error.userFriendlyMessage
                showNetworkError = true
            } else if !shouldShow {
                showNetworkError = false
            }
        }
        .task {
            await authService.restoreSessionIfNeeded()
            await checkNetworkStatus()
        }
    }
    
    private func checkNetworkStatus() async {
        if !networkMonitor.isConnected {
            networkErrorMessage = "No internet connection"
            await MainActor.run {
                showNetworkError = true
            }
        } else {
            do {
                let url = APIConfiguration.shared.baseURL.appendingPathComponent("health")
                var request = URLRequest(url: url, timeoutInterval: 5)
                request.httpMethod = "GET"
                let (_, response) = try await URLSession.shared.data(for: request)
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 500 {
                    networkErrorMessage = "Server is unavailable"
                    await MainActor.run {
                        showNetworkError = true
                    }
                } else {
                    await MainActor.run {
                        showNetworkError = false
                        errorHandler.clearError()
                    }
                }
            } catch {
                let nsError = error as NSError
                if nsError.domain == NSURLErrorDomain {
                    switch nsError.code {
                    case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
                        networkErrorMessage = "No internet connection"
                    case NSURLErrorTimedOut, NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost:
                        networkErrorMessage = "Server is unavailable"
                    default:
                        networkErrorMessage = "Connection error"
                    }
                    await MainActor.run {
                        showNetworkError = true
                    }
                }
            }
        }
    }
}
