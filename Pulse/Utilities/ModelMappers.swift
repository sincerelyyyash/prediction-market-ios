import Foundation
func mapEventDTOToEventDetail(
    _ dto: EventDTO,
    eventIdMap: inout [UInt64: UUID]
) -> EventDetail? {
    let uuid = eventIdMap[dto.id] ?? UUID()
    eventIdMap[dto.id] = uuid
    
    guard let category = EventCategory(rawValue: dto.category.capitalized) else {
        return nil
    }
    let outcomes: [OutcomeMarket] = (dto.outcomes ?? []).compactMap { outcomeDTO in
        mapOutcomeDTOToOutcomeMarket(outcomeDTO)
    }
    
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
        imgUrl: dto.imgUrl,
        outcomes: outcomes
    )
}

private func mapOutcomeDTOToOutcomeMarket(_ outcomeDTO: EventOutcomeDTO) -> OutcomeMarket? {
    if let markets = outcomeDTO.markets, !markets.isEmpty {
        let yesMarket = markets.first { $0.side?.lowercased() == "yes" }
        let noMarket = markets.first { $0.side?.lowercased() == "no" }
        let yesMarketId = yesMarket?.id
        let noMarketId = noMarket?.id
        let yesPrice = priceToProbability(yesMarket?.lastPrice)
        let noPrice = priceToProbability(noMarket?.lastPrice)
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
            volume: 50_000,
            bestBid: noBestBid,
            bestAsk: noBestAsk,
            marketId: noMarketId
        )
        
        return OutcomeMarket(
            name: outcomeDTO.name,
            yes: yesSide,
            no: noSide,
            imgUrl: outcomeDTO.imgUrl
        )
    }
    
    let defaultPrice = 0.5
    
    let yesSide = OutcomeMarketSide(
        side: .yes,
        price: defaultPrice,
        volume: 0,  // Unknown volume
        bestBid: 0.48,
        bestAsk: 0.52,
        marketId: outcomeDTO.yesMarketId  // Use market ID if available
    )
    
    let noSide = OutcomeMarketSide(
        side: .no,
        price: defaultPrice,
        volume: 0,  // Unknown volume
        bestBid: 0.48,
        bestAsk: 0.52,
        marketId: outcomeDTO.noMarketId  // Use market ID if available
    )
    
    return OutcomeMarket(
        name: outcomeDTO.name,
        yes: yesSide,
        no: noSide,
        imgUrl: outcomeDTO.imgUrl
    )
}
func mapOrderbookSnapshotToDemoOrderbook(_ snapshot: OrderbookSnapshot) -> DemoOrderbook {
    let bids = snapshot.bids.map { level in
        DemoOrderbookLevel(
            price: priceToProbability(level.price),
            size: Double(level.quantity)
        )
    }.sorted { $0.price > $1.price }
    
    let asks = snapshot.asks.map { level in
        DemoOrderbookLevel(
            price: priceToProbability(level.price),
            size: Double(level.quantity)
        )
    }.sorted { $0.price < $1.price }
    
    return DemoOrderbook(bids: bids, asks: asks)
}

private func priceToProbability(_ price: UInt64?) -> Double {
    guard let price = price else {
        return 0.5
    }
    return max(0.0, min(1.0, Double(price) / 100.0))
}

