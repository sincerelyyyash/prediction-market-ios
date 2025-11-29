import Foundation

final class PositionService {
    static let shared = PositionService()

    private let client: NetworkClient

    init(client: NetworkClient = .shared) {
        self.client = client
    }

    func getPositions() async throws -> [Position] {
        let response: PositionsResponse = try await client.send(
            path: APIPath.Authenticated.positions,
            method: .get,
            requiresAuth: true
        )
        return response.positions ?? []
    }

    func getPositionsHistory() async throws -> [Position] {
        let response: PositionsResponse = try await client.send(
            path: APIPath.Authenticated.positionsHistory,
            method: .get,
            requiresAuth: true
        )
        return response.positions ?? []
    }

    func getPosition(for marketId: UInt64) async throws -> Position {
        let response: PositionsResponse = try await client.send(
            path: APIPath.Authenticated.positionByMarket(marketId),
            method: .get,
            requiresAuth: true
        )
        guard let position = response.positions?.first else {
            throw APIError.server(statusCode: 404, message: "Position not found")
        }
        return position
    }

    func getPortfolio() async throws -> PortfolioSnapshot {
        let response: PortfolioResponse = try await client.send(
            path: APIPath.Authenticated.portfolio,
            method: .get,
            requiresAuth: true
        )
        guard let snapshot = response.data else {
            throw APIError.decoding(NSError(domain: "Portfolio", code: -1))
        }
        return snapshot
    }
}

