import Foundation

final class TokenManager: AccessTokenProviding {
    static let shared = TokenManager()

    private let keychain = KeychainHelper.shared
    private let service = "com.yash.pulse.auth"
    private let account = "jwt-token"

    private(set) var cachedToken: String?

    var accessToken: String? {
        if let cachedToken {
            return cachedToken
        }
        cachedToken = try? keychain.readString(service: service, account: account)
        return cachedToken
    }

    func store(token: String) throws {
        try keychain.save(token, service: service, account: account)
        cachedToken = token
    }

    func clearToken() {
        try? keychain.delete(service: service, account: account)
        cachedToken = nil
    }

    func isAuthenticated() -> Bool {
        accessToken != nil
    }
}

