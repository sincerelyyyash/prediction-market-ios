import Foundation

final class TokenManager: AccessTokenProviding {
    static let shared = TokenManager()

    private let keychain = KeychainHelper.shared
    private let service = "com.yash.pulse.auth"
    private let account = "jwt-token"

    private let lock = NSLock()
    private var cachedToken: String?

    var accessToken: String? {
        lock.lock()
        defer { lock.unlock() }
        
        if let cachedToken {
            return cachedToken
        }
        cachedToken = try? keychain.readString(service: service, account: account)
        return cachedToken
    }

    func store(token: String) throws {
        lock.lock()
        defer { lock.unlock() }
        
        try keychain.save(token, service: service, account: account)
        cachedToken = token
    }

    func clearToken() {
        lock.lock()
        defer { lock.unlock() }
        
        try? keychain.delete(service: service, account: account)
        cachedToken = nil
    }

    func isAuthenticated() -> Bool {
        accessToken != nil
    }
}

