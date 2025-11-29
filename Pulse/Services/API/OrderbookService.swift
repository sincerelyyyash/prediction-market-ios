import Foundation

final class OrderbookService {
    static let shared = OrderbookService()

    private let client: NetworkClient

    init(client: NetworkClient = .shared) {
        self.client = client
    }

    func getOrderbook(for marketId: UInt64) async throws -> OrderbookSnapshot {
        try await client.send(
            path: APIPath.Public.orderbookForMarket(marketId),
            method: .get
        )
    }

    func getOrderbooks(forEvent eventId: UInt64) async throws -> EventOrderbookSnapshot {
        try await client.send(
            path: APIPath.Public.orderbooksForEvent(eventId),
            method: .get
        )
    }

    func getOrderbooks(forOutcome outcomeId: UInt64) async throws -> OutcomeOrderbookSnapshot {
        try await client.send(
            path: APIPath.Public.orderbooksForOutcome(outcomeId),
            method: .get
        )
    }
}

