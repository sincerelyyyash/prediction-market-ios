import SwiftUI

struct HomeView: View {

    @State private var path: [UUID] = []

    private var trendingEvents: [Event] {
        // Sort by absolute spread between yes/no and take top 10
        Constants.placeholderEvents
            .filter { !$0.isResolved }
            .sorted { abs($0.yesProbability - $0.noProbability) > abs($1.yesProbability - $1.noProbability) }
            .prefix(10)
            .map { $0 }
    }

    // Placeholder for "Your Markets" (user-invested). Replace with real portfolio data later.
    // For demo: pick a few unresolved events by category variety.
    private var yourMarkets: [Event] {
        var picked = [Event]()
        let unresolved = Constants.placeholderEvents.filter { !$0.isResolved }
        // Pick up to 5 across categories
        for category in EventCategory.allCases {
            if let item = unresolved.first(where: { $0.category == category }) {
                picked.append(item)
            }
            if picked.count >= 5 { break }
        }
        if picked.isEmpty {
            return Array(unresolved.prefix(5))
        }
        return picked
    }

    var body: some View {
        NavigationStack(path: $path) {
            GeometryReader { geo in
                ZStack {
                    backgroundGradient(for: geo)
                    ScrollView {
                        VStack(spacing: 16) {
                            Spacer(minLength: 8)

                            // Discover Header
                            PageIntroHeader(
                                title: "Home",
                                subtitle: "Stay on top of the markets you care about"
                            )
                            .padding(.horizontal, 16)

                            // Bookmarks Section
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Bookmarks")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(trendingEvents) { event in
                                            EventCardView(
                                                event: event,
                                                yesAction: { /* hook yes */ },
                                                noAction: { /* hook no */ }
                                            )
                                            // Constrain width so multiple cards can be browsed horizontally
                                            .frame(width: max(260, geo.size.width * 0.72))
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                path.append(event.id)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 4)
                                }
                            }

                            // For You (vertical list)
                            VStack(alignment: .leading, spacing: 10) {
                                Text("For You")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)

                                LazyVStack(spacing: 14) {
                                    ForEach(yourMarkets) { event in
                                        MarketCardView(
                                            content: MarketCardContent(event: event),
                                            handleOpen: {
                                                path.append(event.id)
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, 12)
                            }
                        }
                    }
                }
            }
            .navigationDestination(for: UUID.self) { eventId in
                if let detail = homeEventDetailsByEventId[eventId] {
                    EventView(event: detail)
                        .preferredColorScheme(.dark)
                } else {
                    Text("Event not found")
                        .foregroundColor(.white.opacity(0.8))
                        .background(Color.black.ignoresSafeArea())
                }
            }
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
    init(event: Event) {
        let trimmedYes = max(0.05, min(0.95, event.yesProbability))
        let trimmedNo = max(0.05, min(0.95, event.noProbability))

        self.init(
            title: event.title,
            subtitle: event.description,
            categoryTitle: event.category.rawValue,
            categoryIconName: event.category.systemIcon,
            timeRemainingText: event.timeRemainingText,
            leadingOutcomeName: "Yes vs No",
            leadingDescription: "Top market from your portfolio",
            leadingYesProbability: trimmedYes,
            leadingNoProbability: trimmedNo
        )
    }
}

private extension HomeView {
    // Build EventDetail objects from the events shown on Home
    var homeEventDetailsByEventId: [UUID: EventDetail] {
        // Combine events from both sections, de-duplicate by id
        var map: [UUID: EventDetail] = [:]
        let all = (trendingEvents + yourMarkets)
        var seen = Set<UUID>()
        for ev in all {
            if seen.contains(ev.id) { continue }
            seen.insert(ev.id)
            map[ev.id] = makeDetail(from: ev)
        }
        return map
    }

    func makeDetail(from event: Event) -> EventDetail {
        // Create 2-3 demo outcomes to align with EventView's multi-outcome UI
        let outcomes: [OutcomeMarket] = [
            OutcomeMarket(
                name: "Outcome A",
                yes: OutcomeMarketSide(side: .yes, price: max(0.05, min(0.95, event.yesProbability)), volume: 50_000, bestBid: max(0.0, event.yesProbability - 0.02), bestAsk: min(1.0, event.yesProbability + 0.02)),
                no:  OutcomeMarketSide(side: .no,  price: max(0.05, min(0.95, event.noProbability)),  volume: 50_000, bestBid: max(0.0, event.noProbability - 0.02),  bestAsk: min(1.0, event.noProbability + 0.02))
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

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
}
