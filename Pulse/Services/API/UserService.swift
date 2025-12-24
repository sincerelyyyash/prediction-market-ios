import Foundation

final class UserService {
    static let shared = UserService()

    private let client: NetworkClient

    init(client: NetworkClient = .shared) {
        self.client = client
    }

    func getBalance() async throws -> BalanceResponse {
        try await client.send(
            path: APIPath.Authenticated.balance,
            method: .get,
            requiresAuth: true
        )
    }

    func onramp(amount: Int64) async throws -> OnrampResponse {
        let request = OnrampRequest(amount: amount)
        return try await client.send(
            path: APIPath.Authenticated.onramp,
            method: .post,
            body: request,
            requiresAuth: true
        )
    }

    func getUser(by id: Int64) async throws -> UserProfile {
        let profile: UserProfile = try await client.send(
            path: APIPath.Authenticated.userById(id),
            method: .get,
            requiresAuth: true
        )
        return profile
    }
}

