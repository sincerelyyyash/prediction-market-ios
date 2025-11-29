import Foundation

final class TradeService {
    static let shared = TradeService()

    private let client: NetworkClient

    init(client: NetworkClient = .shared) {
        self.client = client
    }

    func getTrades() async throws -> [Trade] {
        let response: TradesResponse = try await client.send(
            path: APIPath.Authenticated.trades,
            method: .get,
            requiresAuth: true
        )
        return response.trades ?? []
    }

    func getTrade(by tradeId: String) async throws -> Trade {
        let response: TradeDetailResponse = try await client.send(
            path: APIPath.Authenticated.tradeById(tradeId),
            method: .get,
            requiresAuth: true
        )
        return response.trade
    }

    func getTradesByMarket(_ marketId: UInt64) async throws -> [Trade] {
        let response: TradesResponse = try await client.send(
            path: APIPath.Authenticated.tradesByMarket(marketId),
            method: .get,
            requiresAuth: true
        )
        return response.trades ?? []
    }

    func getTradesByUser(_ userId: UInt64) async throws -> [Trade] {
        let response: TradesResponse = try await client.send(
            path: APIPath.Authenticated.tradesByUser(userId),
            method: .get,
            requiresAuth: true
        )
        return response.trades ?? []
    }
}

