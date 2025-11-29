import Foundation

final class OrderService {
    static let shared = OrderService()

    private let client: NetworkClient

    init(client: NetworkClient = .shared) {
        self.client = client
    }

    func placeOrder(_ request: PlaceOrderRequest) async throws -> Order {
        let envelope: APIEnvelope<Order> = try await client.send(
            path: APIPath.Authenticated.placeOrder,
            method: .post,
            body: request,
            requiresAuth: true
        )
        return try envelope.requireData()
    }

    func cancelOrder(_ orderId: UInt64) async throws -> Order {
        let envelope: APIEnvelope<Order> = try await client.send(
            path: APIPath.Authenticated.cancelOrder(orderId),
            method: .post,
            requiresAuth: true
        )
        return try envelope.requireData()
    }

    func modifyOrder(_ orderId: UInt64, request: ModifyOrderRequest) async throws -> Order {
        let envelope: APIEnvelope<Order> = try await client.send(
            path: APIPath.Authenticated.modifyOrder(orderId),
            method: .put,
            body: request,
            requiresAuth: true
        )
        return try envelope.requireData()
    }

    func splitOrder(_ request: SplitOrderRequest) async throws -> Order {
        let envelope: APIEnvelope<Order> = try await client.send(
            path: APIPath.Authenticated.splitOrder,
            method: .post,
            body: request,
            requiresAuth: true
        )
        return try envelope.requireData()
    }

    func mergeOrder(_ request: MergeOrderRequest) async throws -> Order {
        let envelope: APIEnvelope<Order> = try await client.send(
            path: APIPath.Authenticated.mergeOrder,
            method: .post,
            body: request,
            requiresAuth: true
        )
        return try envelope.requireData()
    }

    func getOpenOrders() async throws -> [Order] {
        let envelope: APIEnvelope<[Order]> = try await client.send(
            path: APIPath.Authenticated.openOrders,
            method: .get,
            requiresAuth: true
        )
        return try envelope.requireData()
    }

    func getOrderStatus(_ orderId: UInt64) async throws -> Order {
        let response: OrderDetailResponse = try await client.send(
            path: APIPath.Authenticated.orderStatus(orderId),
            method: .get,
            requiresAuth: true
        )
        return response.order
    }

    func getOrderHistory() async throws -> [Order] {
        let envelope: APIEnvelope<[Order]> = try await client.send(
            path: APIPath.Authenticated.orderHistory,
            method: .get,
            requiresAuth: true
        )
        return try envelope.requireData()
    }

    func getOrdersByUser(_ userId: UInt64) async throws -> [Order] {
        let response: OrderHistoryResponse = try await client.send(
            path: APIPath.Authenticated.ordersByUser(userId),
            method: .get,
            requiresAuth: true
        )
        return response.orders
    }

    func getOrdersByMarket(_ marketId: UInt64) async throws -> [Order] {
        let response: OrderHistoryResponse = try await client.send(
            path: APIPath.Authenticated.ordersByMarket(marketId),
            method: .get,
            requiresAuth: true
        )
        return response.orders
    }
}

