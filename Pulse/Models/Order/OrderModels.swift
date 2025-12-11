import Foundation

enum OrderSide: String, Codable {
    case ask = "Ask"
    case bid = "Bid"
}

enum OrderType: String, Codable {
    case market = "Market"
    case limit = "Limit"
}

struct PlaceOrderRequest: Encodable {
    let marketId: UInt64
    let side: OrderSide
    let orderType: OrderType
    let price: UInt64?
    let quantity: UInt64

    private enum CodingKeys: String, CodingKey {
        case marketId = "market_id"
        case side
        case orderType = "order_type"
        case price
        case quantity
    }
}

struct ModifyOrderRequest: Encodable {
    let price: UInt64?
    let quantity: UInt64?
}

struct SplitOrderRequest: Encodable {
    let market1Id: UInt64
    let market2Id: UInt64
    let amount: UInt64

    private enum CodingKeys: String, CodingKey {
        case market1Id = "market1_id"
        case market2Id = "market2_id"
        case amount
    }
}

struct SplitOrderResponse: Decodable {
    let market1Id: UInt64
    let market2Id: UInt64
    let amount: UInt64

    private enum CodingKeys: String, CodingKey {
        case market1Id = "market1_id"
        case market2Id = "market2_id"
        case amount
    }
}

struct MergeOrderRequest: Encodable {
    let market1Id: UInt64
    let market2Id: UInt64

    private enum CodingKeys: String, CodingKey {
        case market1Id = "market1_id"
        case market2Id = "market2_id"
    }
}

struct MergeOrderResponse: Decodable {
    let market1Id: UInt64
    let market2Id: UInt64

    private enum CodingKeys: String, CodingKey {
        case market1Id = "market1_id"
        case market2Id = "market2_id"
    }
}

struct Order: Decodable, Identifiable, Equatable {
    let orderId: UInt64?
    let marketId: UInt64
    let userId: UInt64
    let price: UInt64
    let originalQuantity: UInt64
    let remainingQuantity: UInt64
    let side: OrderSide
    let orderType: OrderType
    let filledQuantity: UInt64?
    let status: String?
    let createdAt: String?
    let updatedAt: String?
    let cancelledAt: String?
    let filledAt: String?

    var id: UInt64 { orderId ?? marketId }

    var isFilled: Bool {
        remainingQuantity == 0
    }

    private enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case marketId = "market_id"
        case userId = "user_id"
        case price
        case originalQuantity = "original_qty"
        case remainingQuantity = "remaining_qty"
        case side
        case orderType = "order_type"
        case filledQuantity = "filled_qty"
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case cancelledAt = "cancelled_at"
        case filledAt = "filled_at"
    }
}

struct OrderHistoryResponse: Decodable {
    let orders: [Order]
}

struct OrderDetailResponse: Decodable {
    let status: String?
    let message: String?
    let order: Order
}

