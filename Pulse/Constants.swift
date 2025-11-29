
import Foundation
import SwiftUI

struct Constants{
    static let homeString = "Home"
    static let marketString = "Market"
    static let portfolioString = "Portfolio"
    static let profileString = "Profile"
    static let searchString = "Search"
    
    static let onboardingString = "Analyse. Predict. Win."
    static let onboardinButtonString = "Start Trading"
    
    static let homeIconString = "house.fill"
    static let marketIconString = "chart.line.uptrend.xyaxis"
    static let searchIconString = "magnifyingglass"
    static let portfolioIconString = "briefcase.fill"
    static let profileIconString = "person.crop.circle"
}

// MARK: - Shared models used by HomeView

enum EventCategory: String, CaseIterable, Identifiable, Equatable {
    case politics = "Politics"
    case sports = "Sports"
    case finance = "Finance"
    case tech = "Tech"
    case entertainment = "Entertainment"
    case science = "Science"

    var id: String { rawValue }
    var systemIcon: String {
        switch self {
        case .politics: return "building.columns"
        case .sports: return "sportscourt"
        case .finance: return "dollarsign.circle"
        case .tech: return "cpu"
        case .entertainment: return "film"
        case .science: return "atom"
        }
    }
}

enum EventOutcome: String, Equatable {
    case yes
    case no
    case unresolved
}

struct Event: Identifiable, Equatable {
    let id: UUID
    var title: String
    var category: EventCategory
    var isResolved: Bool
    var outcome: EventOutcome
    var yesProbability: Double // 0.0 ... 1.0
    var noProbability: Double  // 0.0 ... 1.0
    var timeRemainingText: String
    var description: String?
}

extension Constants {
    static let placeholderEvents: [Event] = [
        Event(
            id: UUID(),
            title: "Will the S&P 500 close higher this week?",
            category: .finance,
            isResolved: false,
            outcome: .unresolved,
            yesProbability: 0.58,
            noProbability: 0.42,
            timeRemainingText: "3d 4h left",
            description: "Weekly close relative to last Friday."
        ),
        Event(
            id: UUID(),
            title: "Will Team A win the championship?",
            category: .sports,
            isResolved: false,
            outcome: .unresolved,
            yesProbability: 0.36,
            noProbability: 0.64,
            timeRemainingText: "15d left",
            description: "Season outcome market."
        ),
        Event(
            id: UUID(),
            title: "Will a new iPhone be announced by Q3?",
            category: .tech,
            isResolved: false,
            outcome: .unresolved,
            yesProbability: 0.72,
            noProbability: 0.28,
            timeRemainingText: "120d left",
            description: "Major product announcement."
        ),
        Event(
            id: UUID(),
            title: "Will Movie X win Best Picture?",
            category: .entertainment,
            isResolved: false,
            outcome: .unresolved,
            yesProbability: 0.22,
            noProbability: 0.78,
            timeRemainingText: "70d left",
            description: "Award season market."
        ),
        Event(
            id: UUID(),
            title: "Will Country Y hold early elections in 2026?",
            category: .politics,
            isResolved: false,
            outcome: .unresolved,
            yesProbability: 0.41,
            noProbability: 0.59,
            timeRemainingText: "200d left",
            description: "Political developments."
        ),
        Event(
            id: UUID(),
            title: "Will a new exoplanet be confirmed this month?",
            category: .science,
            isResolved: false,
            outcome: .unresolved,
            yesProbability: 0.18,
            noProbability: 0.82,
            timeRemainingText: "25d left",
            description: "Astronomy discovery cadence."
        )
    ]
}

// MARK: - Multi-outcome event placeholders for EventView

enum MarketSideType: String {
    case yes = "Yes"
    case no = "No"

    var color: Color {
        switch self {
        case .yes: return .green
        case .no: return .red
        }
    }
}

struct OutcomeMarketSide: Identifiable, Equatable {
    let id = UUID()
    let side: MarketSideType
    let price: Double   // 0...1 probability-like
    let volume: Double  // notional volume
    let bestBid: Double
    let bestAsk: Double
    let marketId: UInt64? // Market ID for fetching orderbook
}

struct OutcomeMarket: Identifiable, Equatable {
    let id = UUID()
    let name: String // e.g., "Trump"
    let yes: OutcomeMarketSide
    let no: OutcomeMarketSide
}

struct EventDetail: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let subtitle: String?
    let category: EventCategory
    let timeRemainingText: String
    let description: String?
    let imageName: String
    let outcomes: [OutcomeMarket]
}

// MARK: - Orderbook placeholder models

struct DemoOrderbookLevel: Identifiable, Equatable {
    let id = UUID()
    let price: Double   // 0...1
    let size: Double    // quantity or notional
}

struct DemoOrderbook: Equatable {
    var bids: [DemoOrderbookLevel] // sorted desc by price
    var asks: [DemoOrderbookLevel] // sorted asc by price
}

extension Constants {
    // Helper to generate a small ladder around best bid/ask
    private static func ladder(bestBid: Double, bestAsk: Double, steps: Int = 5, tick: Double = 0.01, baseSize: Double = 1_000) -> DemoOrderbook {
        let bids: [DemoOrderbookLevel] = (0..<steps).map { i in
            let p = max(0.0, bestBid - Double(i) * tick)
            let s = baseSize * (1.0 + Double(i) * 0.2)
            return DemoOrderbookLevel(price: p, size: s)
        }
        let asks: [DemoOrderbookLevel] = (0..<steps).map { i in
            let p = min(1.0, bestAsk + Double(i) * tick)
            let s = baseSize * (1.0 + Double(i) * 0.2)
            return DemoOrderbookLevel(price: p, size: s)
        }
        return DemoOrderbook(bids: bids, asks: asks)
    }

    // Builder returns both the EventDetail array and the orderbooks map
    private static func buildEventDetailsAndOrderbooks() -> ([EventDetail], [UUID: [UUID: [MarketSideType: DemoOrderbook]]]) {
        let outcomes: [OutcomeMarket] = [
            OutcomeMarket(
                name: "Trump",
                yes: OutcomeMarketSide(side: .yes, price: 0.61, volume: 125_400, bestBid: 0.60, bestAsk: 0.62, marketId: nil),
                no:  OutcomeMarketSide(side: .no,  price: 0.39, volume: 98_200,  bestBid: 0.38, bestAsk: 0.40, marketId: nil)
            ),
            OutcomeMarket(
                name: "Biden",
                yes: OutcomeMarketSide(side: .yes, price: 0.28, volume: 89_500, bestBid: 0.27, bestAsk: 0.29, marketId: nil),
                no:  OutcomeMarketSide(side: .no,  price: 0.72, volume: 143_200, bestBid: 0.71, bestAsk: 0.73, marketId: nil)
            ),
            OutcomeMarket(
                name: "Obama",
                yes: OutcomeMarketSide(side: .yes, price: 0.08, volume: 22_100, bestBid: 0.07, bestAsk: 0.09, marketId: nil),
                no:  OutcomeMarketSide(side: .no,  price: 0.92, volume: 64_300, bestBid: 0.91, bestAsk: 0.93, marketId: nil)
            )
        ]

        let event = EventDetail(
            title: "Who will win the 2028 US Presidential Election?",
            subtitle: "Major national election with multiple candidates",
            category: .politics,
            timeRemainingText: "200d left",
            description: "Predict the winner. Each outcome has separate Yes and No markets with independent orderbooks. Trade on your beliefs and manage risk with granular markets.",
            imageName: "eventPlaceholder",
            outcomes: outcomes
        )

        var orderbooksForEvent: [UUID: [MarketSideType: DemoOrderbook]] = [:]
        for outcome in outcomes {
            orderbooksForEvent[outcome.id] = [
                .yes: ladder(bestBid: outcome.yes.bestBid, bestAsk: outcome.yes.bestAsk),
                .no:  ladder(bestBid: outcome.no.bestBid,  bestAsk: outcome.no.bestAsk)
            ]
        }

        let eventsArray = [event]
        let orderbooksMap: [UUID: [UUID: [MarketSideType: DemoOrderbook]]] = [
            event.id: orderbooksForEvent
        ]
        return (eventsArray, orderbooksMap)
    }

    // Static lets built from the builder (no self mutation in initializers)
    static let placeholderEventDetails: [EventDetail] = {
        let (events, _) = buildEventDetailsAndOrderbooks()
        return events
    }()

    // Orderbooks: EventDetail.id -> OutcomeMarket.id -> side -> Orderbook
    static let placeholderOrderbooks: [UUID: [UUID: [MarketSideType: DemoOrderbook]]] = {
        let (_, books) = buildEventDetailsAndOrderbooks()
        return books
    }()
}
