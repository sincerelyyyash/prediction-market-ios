import Foundation

struct OrderbookLevel: Decodable, Identifiable, Equatable {
    let price: UInt64
    let quantity: UInt64

    var id: String { "\(price)-\(quantity)" }
}

struct OrderbookSnapshot: Decodable, Equatable {
    let marketId: UInt64
    let bids: [OrderbookLevel]
    let asks: [OrderbookLevel]
    let lastPrice: UInt64?

    private enum CodingKeys: String, CodingKey {
        case marketId = "market_id"
        case bids
        case asks
        case lastPrice = "last_price"
    }
}

struct MarketOrderbookSnapshot: Decodable, Equatable {
    let marketId: UInt64
    let side: String?
    let snapshot: OrderbookSnapshot

    private enum CodingKeys: String, CodingKey {
        case marketId = "market_id"
        case side
        case snapshot
    }
}

struct OutcomeOrderbookSnapshot: Decodable, Equatable {
    let outcomeId: UInt64
    let eventId: UInt64?
    let markets: [MarketOrderbookSnapshot]

    private enum CodingKeys: String, CodingKey {
        case outcomeId = "outcome_id"
        case eventId = "event_id"
        case markets
    }
}

struct EventOrderbookSnapshot: Decodable, Equatable {
    let eventId: UInt64
    let outcomes: [OutcomeOrderbookSnapshot]

    private enum CodingKeys: String, CodingKey {
        case eventId = "event_id"
        case outcomes
    }
}

