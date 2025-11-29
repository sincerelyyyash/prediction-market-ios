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
            winningOutcomeId: response.event.winningOutcomeId
        )
    }
}

