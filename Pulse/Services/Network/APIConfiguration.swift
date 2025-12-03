import Foundation

enum APIEnvironment {
    case development
    case production

    var baseURLString: String {
        switch self {
        case .development:
           return "http://127.0.0.1:8000"
        case .production:
            return "http://127.0.0.1:8000"
        }
    }
}

struct APIConfiguration {
    static let shared = APIConfiguration()

    let environment: APIEnvironment
    let requestTimeout: TimeInterval = 10

    private init(environment: APIEnvironment = .production) {
        self.environment = environment
    }

    var baseURL: URL {
        guard let url = URL(string: environment.baseURLString) else {
            fatalError("Invalid base URL for environment: \(environment)")
        }
        return url
    }
}

enum APIPath {
    enum Public {
        static let signup = "/user/signup"
        static let signin = "/user/signin"
        static let events = "/events"
        static func event(id: UInt64) -> String { "/events/\(id)" }
        static let searchEvents = "/events/search"
        static func orderbookForMarket(_ marketId: UInt64) -> String { "/orderbooks/market/\(marketId)" }
        static func orderbooksForEvent(_ eventId: UInt64) -> String { "/orderbooks/event/\(eventId)" }
        static func orderbooksForOutcome(_ outcomeId: UInt64) -> String { "/orderbooks/outcome/\(outcomeId)" }
        static let health = "/health"
    }

    enum Authenticated {
        static let balance = "/get-balance"
        static let onramp = "/onramp"

        // Orders
        static let placeOrder = "/orders"
        static func cancelOrder(_ orderId: UInt64) -> String { "/orders/\(orderId)/cancel" }
        static func modifyOrder(_ orderId: UInt64) -> String { "/orders/\(orderId)" }
        static let splitOrder = "/orders/split"
        static let mergeOrder = "/orders/merge"
        static let openOrders = "/orders"
        static func orderStatus(_ orderId: UInt64) -> String { "/orders/\(orderId)" }
        static let orderHistory = "/orders/history"
        static func ordersByUser(_ userId: UInt64) -> String { "/orders/user/\(userId)" }
        static func ordersByMarket(_ marketId: UInt64) -> String { "/orders/market/\(marketId)" }

        // Positions & portfolio
        static let positions = "/positions"
        static let positionsHistory = "/positions/history"
        static func positionByMarket(_ marketId: UInt64) -> String { "/positions/\(marketId)" }
        static let portfolio = "/positions/portfolio"

        // Trades
        static let trades = "/trades"
        static func tradeById(_ tradeId: String) -> String { "/trades/\(tradeId)" }
        static func tradesByMarket(_ marketId: UInt64) -> String { "/trades/market/\(marketId)" }
        static func tradesByUser(_ userId: UInt64) -> String { "/trades/user/\(userId)" }

        // Users
        static func userById(_ userId: Int64) -> String { "/users/\(userId)" }

        // Bookmarks & For You
        static let bookmarks = "/user/bookmarks"
        static let forYou = "/user/markets/for-you"
    }
}

