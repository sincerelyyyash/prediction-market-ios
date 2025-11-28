import SwiftUI

struct MarketView: View {
    @State private var searchText = ""
    @State private var selectedCategory: EventCategory?
    @State private var path: [UUID] = []

    var body: some View {
        NavigationStack(path: $path) {
            GeometryReader { geo in
                ZStack {
                    backgroundGradient(for: geo)
                    VStack(spacing: 0) {
                        Spacer(minLength: 8)
                        header
                            .padding(.horizontal, 16)
                            .padding(.bottom, 6)
                        ScrollView {
                            LazyVStack(spacing: 14) {
                                ForEach(filteredMarkets) { detail in
                                    MarketCardView(
                                        content: MarketCardContent(detail: detail),
                                        handleOpen: {
                                            path.append(detail.id)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                    }
                }
            }
            .navigationDestination(for: UUID.self) { id in
                // Try to find in derived list first
                if let detail = filteredMarkets.first(where: { $0.id == id }) {
                    EventView(event: detail)
                        .preferredColorScheme(.dark)
                }
                // Fallback to original placeholderEventDetails (demo)
                else if let detail = Constants.placeholderEventDetails.first(where: { $0.id == id }) {
                    EventView(event: detail)
                        .preferredColorScheme(.dark)
                } else {
                    Text("Market not found")
                        .foregroundColor(.white.opacity(0.8))
                        .background(Color.black.ignoresSafeArea())
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            PageIntroHeader(
                title: "Markets",
                subtitle: "Browse every live contract and filter with precision"
            )
            HomeHeaderView(
                searchText: $searchText,
                selectedCategory: $selectedCategory
            )
        }
    }

    // Build multiple EventDetail-like items from the many placeholder Events
    private var derivedEventDetails: [EventDetail] {
        Constants.placeholderEvents.map { event in
            // Create 2-3 mock outcomes per event to fit the multi-outcome UI
            let outcomes: [OutcomeMarket] = [
                OutcomeMarket(
                    name: "Outcome A",
                    yes: OutcomeMarketSide(side: .yes, price: max(0.05, min(0.95, event.yesProbability)), volume: 50_000, bestBid: max(0.0, event.yesProbability - 0.02), bestAsk: min(1.0, event.yesProbability + 0.02)),
                    no:  OutcomeMarketSide(side: .no,  price: max(0.05, min(0.95, event.noProbability)),  volume: 50_000, bestBid: max(0.0, event.noProbability - 0.02), bestAsk: min(1.0, event.noProbability + 0.02))
                ),
                OutcomeMarket(
                    name: "Outcome B",
                    yes: OutcomeMarketSide(side: .yes, price: max(0.05, min(0.95, 1 - event.yesProbability * 0.7)), volume: 40_000, bestBid: 0.3, bestAsk: 0.32),
                    no:  OutcomeMarketSide(side: .no,  price: max(0.05, min(0.95, 1 - event.noProbability * 0.7)),  volume: 40_000, bestBid: 0.68, bestAsk: 0.70)
                ),
                OutcomeMarket(
                    name: "Outcome C",
                    yes: OutcomeMarketSide(side: .yes, price: 0.12, volume: 24_000, bestBid: 0.11, bestAsk: 0.13),
                    no:  OutcomeMarketSide(side: .no,  price: 0.88, volume: 24_000, bestBid: 0.87, bestAsk: 0.89)
                )
            ]

            return EventDetail(
                title: event.title,
                subtitle: event.description,
                category: event.category,
                timeRemainingText: event.timeRemainingText,
                description: event.description,
                imageName: "eventPlaceholder",
                outcomes: outcomes
            )
        }
    }

    // Filters now operate on the derived multi-outcome details
    private var filteredMarkets: [EventDetail] {
        derivedEventDetails.filter { detail in
            let matchesCategory = selectedCategory == nil || detail.category == selectedCategory
            let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            let matchesSearch = trimmed.isEmpty ||
                detail.title.localizedCaseInsensitiveContains(trimmed) ||
                (detail.subtitle?.localizedCaseInsensitiveContains(trimmed) ?? false)
            return matchesCategory && matchesSearch
        }
    }

    private func backgroundGradient(for geo: GeometryProxy) -> some View {
        ZStack {
            Color.black.ignoresSafeArea()
            RadialGradient(
                gradient: Gradient(stops: [
                    .init(color: .white, location: 0.0),
                    .init(color: Color(red: 0.7, green: 0.7, blue: 0.75), location: 0.0),
                    .init(color: .black, location: 0.4)
                ]),
                center: .top,
                startRadius: 0,
                endRadius: max(geo.size.width, geo.size.height) * 0.9
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
    }
}

private extension MarketCardContent {
    init(detail: EventDetail) {
        let leadingOutcome = detail.outcomes.sorted { $0.yes.price > $1.yes.price }.first
        let defaultName = detail.outcomes.first?.name ?? "Outcome"
        let yesProbability = leadingOutcome?.yes.price ?? 0.5
        let noProbability = leadingOutcome?.no.price ?? 0.5

        self.init(
            title: detail.title,
            subtitle: detail.subtitle,
            categoryTitle: detail.category.rawValue,
            categoryIconName: detail.category.systemIcon,
            timeRemainingText: detail.timeRemainingText,
            leadingOutcomeName: leadingOutcome?.name ?? defaultName,
            leadingDescription: leadingOutcome == nil ? "Tap to view market" : "Highest conviction right now",
            leadingYesProbability: yesProbability,
            leadingNoProbability: noProbability
        )
    }
}

#Preview {
    MarketView()
        .preferredColorScheme(.dark)
}
