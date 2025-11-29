import Foundation

struct Position: Decodable, Identifiable, Equatable {
    let userId: Int64
    let marketId: Int64
    let quantity: Int64
    let createdAt: String?
    let updatedAt: String?

    var id: String { "\(userId)-\(marketId)" }

    private enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case marketId = "market_id"
        case quantity
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct PositionsResponse: Decodable {
    let status: String?
    let message: String?
    let positions: [Position]?
    let count: Int?
}

struct PortfolioSnapshot: Decodable {
    let balance: Int64?
    let totalValue: Int64?
    let pnl: Int64?
    let positions: [Position]?

    private enum CodingKeys: String, CodingKey {
        case balance
        case totalValue = "total_value"
        case pnl
        case positions
    }
}

struct PortfolioResponse: Decodable {
    let status: String?
    let message: String?
    let data: PortfolioSnapshot?
}

