import Foundation

struct Trade: Decodable, Identifiable, Equatable {
    let tradeId: String
    let marketId: UInt64
    let takerOrderId: UInt64
    let makerOrderId: UInt64
    let takerUserId: UInt64
    let makerUserId: UInt64
    let price: UInt64
    let quantity: UInt64
    let takerSide: String
    let timestamp: String?

    var id: String { tradeId }

    private enum CodingKeys: String, CodingKey {
        case tradeId = "trade_id"
        case marketId = "market_id"
        case takerOrderId = "taker_order_id"
        case makerOrderId = "maker_order_id"
        case takerUserId = "taker_user_id"
        case makerUserId = "maker_user_id"
        case price
        case quantity
        case takerSide = "taker_side"
        case timestamp
    }
}

struct TradesResponse: Decodable {
    let status: String?
    let message: String?
    let trades: [Trade]?
    let count: Int?
}

struct TradeDetailResponse: Decodable {
    let status: String?
    let message: String?
    let trade: Trade
}

