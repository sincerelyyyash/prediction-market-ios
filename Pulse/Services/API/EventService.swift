import Foundation

final class EventService {
    static let shared = EventService()

    private let client: NetworkClient

    init(client: NetworkClient = .shared) {
        self.client = client
    }

    func getEvents() async throws -> [EventDTO] {
        let response: EventListResponse = try await client.send(
            path: APIPath.Public.events,
            method: .get
        )
        return response.events
    }

    func getEvent(by id: UInt64) async throws -> EventDTO {
        let response: EventDetailResponse = try await client.send(
            path: APIPath.Public.event(id: id),
            method: .get
        )
        return mapDetailResponse(response)
    }

    func searchEvents(query: EventSearchQuery) async throws -> [EventDTO] {
        let response: EventListResponse = try await client.send(
            path: APIPath.Public.searchEvents,
            method: .get,
            queryItems: query.queryItems
        )
        return response.events
    }

    func getBookmarkedEvents() async throws -> [EventDTO] {
        let response: BookmarkEventsResponse = try await client.send(
            path: APIPath.Authenticated.bookmarks,
            method: .get,
            requiresAuth: true
        )

        // Map bookmark payload (market-centric) into flat EventDTOs
        return response.bookmarks.map { bookmark in
            let event = bookmark.market.event
            return EventDTO(
                id: event.id,
                slug: event.slug,
                title: event.title,
                description: event.description,
                category: event.category,
                status: event.status,
                resolvedAt: nil,
                createdBy: nil,
                outcomes: nil,
                winningOutcomeId: nil,
                imgUrl: event.imgUrl
            )
        }
    }

    func getForYouEvents() async throws -> [EventDTO] {
        let response: ForYouMarketsResponse = try await client.send(
            path: APIPath.Authenticated.forYou,
            method: .get,
            requiresAuth: true
        )

        // Map recommended markets payload into flat EventDTOs
        return response.markets.map { marketWrapper in
            let event = marketWrapper.market.event
            return EventDTO(
                id: event.id,
                slug: event.slug,
                title: event.title,
                description: event.description,
                category: event.category,
                status: event.status,
                resolvedAt: nil,
                createdBy: nil,
                outcomes: nil,
                winningOutcomeId: nil,
                imgUrl: event.imgUrl
            )
        }
    }

    private func mapDetailResponse(_ response: EventDetailResponse) -> EventDTO {
        EventDTO(
            id: response.event.id,
            slug: response.event.slug,
            title: response.event.title,
            description: response.event.description,
            category: response.event.category,
            status: response.event.status,
            resolvedAt: response.event.resolvedAt,
            createdBy: response.event.createdBy,
            outcomes: response.outcomes,
            winningOutcomeId: response.event.winningOutcomeId,
            imgUrl: response.event.imgUrl
        )
    }
}

// MARK: - Helper Response Types

/// Bookmarks endpoint payload: `/user/bookmarks`
private struct BookmarkEventsResponse: Decodable {
    struct BookmarkEvent: Decodable {
        let id: UInt64
        let slug: String?
        let title: String
        let description: String?
        let category: String
        let status: String
        let imgUrl: String?

        private enum CodingKeys: String, CodingKey {
            case id
            case slug
            case title
            case description
            case category
            case status
            case imgUrl = "img_url"
        }
    }

    struct BookmarkMarket: Decodable {
        let side: String?
        let lastPrice: UInt64?
        let event: BookmarkEvent

        private enum CodingKeys: String, CodingKey {
            case side
            case lastPrice = "last_price"
            case event
        }
    }

    struct BookmarkItem: Decodable {
        let marketId: UInt64
        let market: BookmarkMarket

        private enum CodingKeys: String, CodingKey {
            case marketId = "market_id"
            case market
        }
    }

    let userId: UInt64
    let bookmarks: [BookmarkItem]
    let count: Int?

    private enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case bookmarks
        case count
    }
}

/// For You markets endpoint payload: `/user/markets/for-you`
private struct ForYouMarketsResponse: Decodable {
    struct ForYouEvent: Decodable {
        let id: UInt64
        let slug: String?
        let title: String
        let description: String?
        let category: String
        let status: String
        let imgUrl: String?

        private enum CodingKeys: String, CodingKey {
            case id
            case slug
            case title
            case description
            case category
            case status
            case imgUrl = "img_url"
        }
    }

    struct ForYouOutcome: Decodable {
        let id: UInt64
        let name: String
        let imgUrl: String?

        private enum CodingKeys: String, CodingKey {
            case id
            case name
            case imgUrl = "img_url"
        }
    }

    struct ForYouMarket: Decodable {
        let side: String?
        let lastPrice: UInt64?
        let outcome: ForYouOutcome
        let event: ForYouEvent

        private enum CodingKeys: String, CodingKey {
            case side
            case lastPrice = "last_price"
            case outcome
            case event
        }
    }

    struct ForYouItem: Decodable {
        let marketId: UInt64
        let market: ForYouMarket

        private enum CodingKeys: String, CodingKey {
            case marketId = "market_id"
            case market
        }
    }

    let userId: UInt64
    let markets: [ForYouItem]
    let count: Int?
    let limit: Int?
    let offset: Int?

    private enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case markets
        case count
        case limit
        case offset
    }
}

