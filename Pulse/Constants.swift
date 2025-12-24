
import Foundation
import SwiftUI

struct Constants{
    static let homeString = "Home"
    static let marketString = "Market"
    static let portfolioString = "Portfolio"
    static let profileString = "Profile"
    
    static let onboardingString = "Analyse. Predict. Win."
    static let onboardinButtonString = "Start Trading"
    
    static let homeIconString = "house.fill"
    static let marketIconString = "chart.line.uptrend.xyaxis"
    static let portfolioIconString = "briefcase.fill"
    static let profileIconString = "person.crop.circle"
}

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
    var yesProbability: Double
    var noProbability: Double
    var timeRemainingText: String
    var description: String?
    var imgUrl: String?
}

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
    let price: Double
    let volume: Double
    let bestBid: Double
    let bestAsk: Double
    let marketId: UInt64?
}

struct OutcomeMarket: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let yes: OutcomeMarketSide
    let no: OutcomeMarketSide
    let imgUrl: String?
}

struct EventDetail: Identifiable, Equatable {
    let id: UUID
    let title: String
    let subtitle: String?
    let category: EventCategory
    let timeRemainingText: String
    let description: String?
    let imageName: String
    let imgUrl: String?
    let outcomes: [OutcomeMarket]
}

struct DemoOrderbookLevel: Identifiable, Equatable {
    let id = UUID()
    let price: Double
    let size: Double
}

struct DemoOrderbook: Equatable {
    var bids: [DemoOrderbookLevel]
    var asks: [DemoOrderbookLevel]
}

extension Constants {
    static let placeholderEventDetails: [EventDetail] = [
        EventDetail(
            id: UUID(),
            title: "Who will win the 2028 US Presidential Election?",
            subtitle: "Major national election with multiple candidates",
            category: .politics,
            timeRemainingText: "200d left",
            description: "Predict the winner. Each outcome has separate Yes and No markets with independent orderbooks. Trade on your beliefs and manage risk with granular markets.",
            imageName: "eventPlaceholder",
            imgUrl: nil,
            outcomes: [
                OutcomeMarket(
                    name: "Trump",
                    yes: OutcomeMarketSide(side: .yes, price: 0.61, volume: 125_400, bestBid: 0.60, bestAsk: 0.62, marketId: nil),
                    no:  OutcomeMarketSide(side: .no,  price: 0.39, volume: 98_200,  bestBid: 0.38, bestAsk: 0.40, marketId: nil),
                    imgUrl: nil
                ),
                OutcomeMarket(
                    name: "Biden",
                    yes: OutcomeMarketSide(side: .yes, price: 0.28, volume: 89_500, bestBid: 0.27, bestAsk: 0.29, marketId: nil),
                    no:  OutcomeMarketSide(side: .no,  price: 0.72, volume: 143_200, bestBid: 0.71, bestAsk: 0.73, marketId: nil),
                    imgUrl: nil
                ),
                OutcomeMarket(
                    name: "Obama",
                    yes: OutcomeMarketSide(side: .yes, price: 0.08, volume: 22_100, bestBid: 0.07, bestAsk: 0.09, marketId: nil),
                    no:  OutcomeMarketSide(side: .no,  price: 0.92, volume: 64_300, bestBid: 0.91, bestAsk: 0.93, marketId: nil),
                    imgUrl: nil
                )
            ]
        )
    ]
}

