import Foundation

struct EventSearchQuery {
    var q: String?
    var category: String?
    var status: String?

    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []
        if let q, !q.isEmpty {
            items.append(URLQueryItem(name: "q", value: q))
        }
        if let category, !category.isEmpty {
            items.append(URLQueryItem(name: "category", value: category))
        }
        if let status, !status.isEmpty {
            items.append(URLQueryItem(name: "status", value: status))
        }
        return items
    }
}

struct EventDTO: Decodable, Identifiable, Equatable {
    let id: UInt64
    let slug: String?
    let title: String
    let description: String?
    let category: String
    let status: String
    let resolvedAt: String?
    let createdBy: UInt64?
    let outcomes: [EventOutcomeDTO]?
    let winningOutcomeId: UInt64?

    private enum CodingKeys: String, CodingKey {
        case id = "event_id"
        case slug
        case title
        case description
        case category
        case status
        case resolvedAt = "resolved_at"
        case createdBy = "created_by"
        case outcomes
        case winningOutcomeId = "winning_outcome_id"
    }
}

struct EventOutcomeDTO: Decodable, Identifiable, Equatable {
    let id: UInt64
    let eventId: UInt64?
    let name: String
    let status: String
    let yesMarketId: UInt64?
    let noMarketId: UInt64?
    let markets: [EventOutcomeMarketDTO]?

    private enum CodingKeys: String, CodingKey {
        case id = "outcome_id"
        case eventId = "event_id"
        case name
        case status
        case yesMarketId = "yes_market_id"
        case noMarketId = "no_market_id"
        case markets
    }
}

struct EventOutcomeMarketDTO: Decodable, Identifiable, Equatable {
    let identifier: UInt64
    let outcomeId: UInt64
    let side: String?
    let lastPrice: UInt64?

    var id: UInt64 { identifier }

    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case outcomeId = "outcome_id"
        case side
        case lastPrice = "last_price"
    }
}

struct EventListResponse: Decodable {
    let status: String?
    let message: String?
    let events: [EventDTO]
    let count: Int?
}

struct EventDetailResponse: Decodable {
    let status: String?
    let message: String?
    let event: EventCoreDTO
    let outcomes: [EventOutcomeDTO]
}

struct EventCoreDTO: Decodable {
    let id: UInt64
    let slug: String?
    let title: String
    let description: String?
    let category: String
    let status: String
    let resolvedAt: String?
    let winningOutcomeId: UInt64?
    let createdBy: UInt64?

    private enum CodingKeys: String, CodingKey {
        case id
        case slug
        case title
        case description
        case category
        case status
        case resolvedAt = "resolved_at"
        case winningOutcomeId = "winning_outcome_id"
        case createdBy = "created_by"
    }
}

