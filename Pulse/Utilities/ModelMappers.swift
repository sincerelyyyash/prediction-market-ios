import Foundation

// MARK: - Event Mapping

/// Maps EventDTO from API to EventDetail UI model
func mapEventDTOToEventDetail(
    _ dto: EventDTO,
    eventIdMap: inout [UInt64: UUID]
) -> EventDetail? {
    let uuid = eventIdMap[dto.id] ?? UUID()
    eventIdMap[dto.id] = uuid
    
    guard let category = EventCategory(rawValue: dto.category.capitalized) else {
        return nil
    }
    
    // Map outcomes to OutcomeMarket objects
    let outcomes: [OutcomeMarket] = (dto.outcomes ?? []).compactMap { outcomeDTO in
        mapOutcomeDTOToOutcomeMarket(outcomeDTO)
    }
    
    // If no outcomes, return nil or create a default outcome
    guard !outcomes.isEmpty else {
        return nil
    }
    
    let isResolved = dto.status.uppercased() == "RESOLVED"
    let timeRemainingText = isResolved ? "Resolved" : dto.status.capitalized
    
    return EventDetail(
        id: uuid,
        title: dto.title,
        subtitle: dto.description,
        category: category,
        timeRemainingText: timeRemainingText,
        description: dto.description,
        imageName: "eventPlaceholder",
        outcomes: outcomes
    )
}

/// Maps EventOutcomeDTO to OutcomeMarket UI model
private func mapOutcomeDTOToOutcomeMarket(_ outcomeDTO: EventOutcomeDTO) -> OutcomeMarket? {
    guard let markets = outcomeDTO.markets, !markets.isEmpty else {
        return nil
    }
    
    // Find Yes and No markets
    let yesMarket = markets.first { $0.side?.lowercased() == "yes" }
    let noMarket = markets.first { $0.side?.lowercased() == "no" }
    
    // Extract market IDs
    let yesMarketId = yesMarket?.id
    let noMarketId = noMarket?.id
    
    // Convert last price from UInt64 (cents) to Double (0.0-1.0 probability)
    let yesPrice = priceToProbability(yesMarket?.lastPrice)
    let noPrice = priceToProbability(noMarket?.lastPrice)
    
    // For now, use default values for volume, bestBid, bestAsk
    // These could be enhanced by fetching orderbook data
    let yesBestBid = max(0.0, yesPrice - 0.02)
    let yesBestAsk = min(1.0, yesPrice + 0.02)
    let noBestBid = max(0.0, noPrice - 0.02)
    let noBestAsk = min(1.0, noPrice + 0.02)
    
    let yesSide = OutcomeMarketSide(
        side: .yes,
        price: yesPrice,
        volume: 50_000, // Default volume, could be fetched from orderbook
        bestBid: yesBestBid,
        bestAsk: yesBestAsk,
        marketId: yesMarketId
    )
    
    let noSide = OutcomeMarketSide(
        side: .no,
        price: noPrice,
        volume: 50_000, // Default volume, could be fetched from orderbook
        bestBid: noBestBid,
        bestAsk: noBestAsk,
        marketId: noMarketId
    )
    
    return OutcomeMarket(
        name: outcomeDTO.name,
        yes: yesSide,
        no: noSide
    )
}

// MARK: - Orderbook Mapping

/// Maps OrderbookSnapshot from API to DemoOrderbook UI model
func mapOrderbookSnapshotToDemoOrderbook(_ snapshot: OrderbookSnapshot) -> DemoOrderbook {
    let bids = snapshot.bids.map { level in
        DemoOrderbookLevel(
            price: priceToProbability(level.price),
            size: Double(level.quantity)
        )
    }.sorted { $0.price > $1.price } // Sort descending by price
    
    let asks = snapshot.asks.map { level in
        DemoOrderbookLevel(
            price: priceToProbability(level.price),
            size: Double(level.quantity)
        )
    }.sorted { $0.price < $1.price } // Sort ascending by price
    
    return DemoOrderbook(bids: bids, asks: asks)
}

// MARK: - Helper Functions

/// Converts price from UInt64 (0-100 representing 0-100%) to Double probability (0.0-1.0)
private func priceToProbability(_ price: UInt64?) -> Double {
    guard let price = price else {
        return 0.5 // Default to 50% if no price
    }
    // Price is 0-100 (percentage), convert to probability (0.0-1.0)
    return max(0.0, min(1.0, Double(price) / 100.0))
}

