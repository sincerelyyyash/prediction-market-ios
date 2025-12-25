import Combine
import Foundation

final class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published private(set) var session: AuthSession?

    private let sessionStorageKey = "pulse.auth.session"
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
            persistSession(newSession)
        }

        return newSession
    }

    @MainActor
    func restoreSessionIfNeeded() async {
        guard session == nil, tokenManager.isAuthenticated() else { return }

        if let stored = loadStoredSession() {
            do {
                _ = try await UserService.shared.getUser(by: Int64(stored.user.id))
                session = stored
                return
            } catch {
                signOut()
                return
            }
        }

        guard let token = tokenManager.accessToken,
              let userId = decodeUserId(from: token) else {
            signOut()
            return
        }

        do {
            let profile = try await UserService.shared.getUser(by: Int64(userId))
            let authUser = AuthenticatedUser(
                id: userId,
                email: profile.email,
                name: profile.name,
                balance: profile.balance
            )
            let rebuilt = AuthSession(token: token, user: authUser)
            session = rebuilt
            persistSession(rebuilt)
        } catch {
            signOut()
        }
    }

    @MainActor
    func signOut() {
        tokenManager.clearToken()
        session = nil
        clearStoredSession()
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

private extension AuthService {
    struct StoredSession: Codable {
        let token: String
        let user: AuthenticatedUser
    }

    func persistSession(_ session: AuthSession) {
        let stored = StoredSession(token: session.token, user: session.user)
        if let data = try? JSONEncoder().encode(stored) {
            UserDefaults.standard.set(data, forKey: sessionStorageKey)
        }
    }

    func loadStoredSession() -> AuthSession? {
        guard let data = UserDefaults.standard.data(forKey: sessionStorageKey),
              let stored = try? JSONDecoder().decode(StoredSession.self, from: data) else {
            return nil
        }
        return AuthSession(token: stored.token, user: stored.user)
    }

    func clearStoredSession() {
        UserDefaults.standard.removeObject(forKey: sessionStorageKey)
    }

    func decodeUserId(from token: String) -> UInt64? {
        let parts = token.split(separator: ".")
        guard parts.count >= 2 else { return nil }
        let payloadPart = parts[1]
        let paddedLength = ((payloadPart.count + 3) / 4) * 4
        let padded = payloadPart.padding(toLength: paddedLength, withPad: "=", startingAt: 0)
        guard let data = Data(base64Encoded: padded),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        if let sub = json["sub"] as? Int {
            return sub >= 0 ? UInt64(sub) : nil
        }
        if let sub = json["sub"] as? Int64 {
            return sub >= 0 ? UInt64(sub) : nil
        }
        if let sub = json["sub"] as? UInt64 {
            return sub
        }
        return nil
    }
}

