import Combine
import Foundation

final class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published private(set) var session: AuthSession?

    private let client: NetworkClient
    private let tokenManager: TokenManager

    init(
        client: NetworkClient = .shared,
        tokenManager: TokenManager = .shared
    ) {
        self.client = client
        self.tokenManager = tokenManager
        self.client.tokenProvider = tokenManager
    }

    var isAuthenticated: Bool {
        tokenManager.isAuthenticated()
    }

    func signUp(name: String, email: String, password: String) async throws -> AuthSession {
        let request = SignUpRequest(name: name, email: email, password: password)
        let response: SignUpResponse = try await client.send(
            path: APIPath.Public.signup,
            method: .post,
            body: request
        )

        try tokenManager.store(token: response.token)
        let newSession = AuthSession(token: response.token, user: response.user)
        
        await MainActor.run {
            session = newSession
        }

        return newSession
    }

    func signIn(email: String, password: String) async throws -> AuthSession {
        let request = SignInRequest(email: email, password: password)
        let response: AuthResponse = try await client.send(
            path: APIPath.Public.signin,
            method: .post,
            body: request
        )

        try tokenManager.store(token: response.token)
        let newSession = AuthSession(token: response.token, user: response.user)
        
        await MainActor.run {
        session = newSession
        }

        return newSession
    }

    @MainActor
    func restoreSessionIfNeeded() {
        guard session == nil, tokenManager.isAuthenticated() else { return }
        // User data is not persisted yet; session will be refreshed after next sign-in flow.
    }

    @MainActor
    func signOut() {
        tokenManager.clearToken()
        session = nil
    }
}

private extension String {
    var maskedEmail: String {
        guard let at = firstIndex(of: "@") else { return self }
        let prefix = distance(from: startIndex, to: at)
        if prefix <= 2 { return self }
        let start = index(startIndex, offsetBy: 2)
        let mask = String(repeating: "*", count: prefix - 2)
        return replacingCharacters(in: start..<at, with: mask)
    }
}

