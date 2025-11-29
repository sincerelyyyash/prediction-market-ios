import SwiftUI

struct HomeView: View {

    @State private var path: [UUID] = []
    @State private var events: [Event] = []
    @State private var eventIdMap: [UInt64: UUID] = [:]
    @State private var uuidToEventIdMap: [UUID: UInt64] = [:]
    @State private var eventDetailsCache: [UUID: EventDetail] = [:]
    @State private var isLoading = false
    @State private var errorMessage: String?

    private var trendingEvents: [Event] {
        events.filter { !$0.isResolved }.prefix(10).map { $0 }
    }

    private var yourMarkets: [Event] {
        events.filter { !$0.isResolved }.prefix(5).map { $0 }
    }

    var body: some View {
        NavigationStack(path: $path) {
            GeometryReader { geo in
                ZStack {
                    backgroundGradient(for: geo)
                    contentBody(geo: geo)
                }
            }
            .navigationDestination(for: UUID.self) { eventId in
                EventDetailView(
                    eventId: eventId,
                    cachedDetail: eventDetailsCache[eventId],
                    uuidToEventIdMap: uuidToEventIdMap,
                    eventDetailsCache: $eventDetailsCache
                )
            }
        }
        .task {
            await loadEvents()
        }
    }

    @ViewBuilder
    private func contentBody(geo: GeometryProxy) -> some View {
        if isLoading {
            ProgressView("Loading events...")
                .progressViewStyle(.circular)
                .tint(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage {
            VStack(spacing: 12) {
                Text("Unable to load events")
                    .font(.headline)
                    .foregroundColor(.white)
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                Button("Try Again", action: { Task { await loadEvents() } })
                    .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                VStack(spacing: 16) {
                    Spacer(minLength: 8)

                    PageIntroHeader(
                        title: "Home",
                        subtitle: "Stay on top of the markets you care about"
                    )
                    .padding(.horizontal, 16)

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
                                        yesAction: {},
                                        noAction: {}
                                    )
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

    private func loadEvents() async {
        guard !isLoading else { return }
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        do {
            let remoteEvents = try await EventService.shared.getEvents()
            await MainActor.run {
                events = remoteEvents.compactMap { map(dto: $0) }
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }

    private func map(dto: EventDTO) -> Event? {
        let uuid = eventIdMap[dto.id] ?? UUID()
        eventIdMap[dto.id] = uuid
        uuidToEventIdMap[uuid] = dto.id

        let category = EventCategory(rawValue: dto.category.capitalized) ?? .finance
        let isResolved = dto.status.uppercased() == "RESOLVED"
        let yesProbability = probability(from: dto, side: "yes")
        let noProbability = max(0.0, min(1.0, 1.0 - yesProbability))

        return Event(
            id: uuid,
            title: dto.title,
            category: category,
            isResolved: isResolved,
            outcome: .unresolved,
            yesProbability: yesProbability,
            noProbability: noProbability,
            timeRemainingText: dto.status.capitalized,
            description: dto.description
        )
    }

    private func probability(from dto: EventDTO, side: String) -> Double {
        guard
            let market = dto.outcomes?
                .compactMap({ outcome in
                    outcome.markets?.first(where: { $0.side?.lowercased() == side })
                })
                .first,
            let lastPrice = market.lastPrice
        else { return 0.5 }

        return max(0.05, min(0.95, Double(lastPrice) / 100.0))
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

// MARK: - EventDetailView Helper

private struct EventDetailView: View {
    let eventId: UUID
    let cachedDetail: EventDetail?
    let uuidToEventIdMap: [UUID: UInt64]
    @Binding var eventDetailsCache: [UUID: EventDetail]
    
    @State private var eventDetail: EventDetail?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading event details...")
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.ignoresSafeArea())
            } else if let errorMessage {
                VStack(spacing: 12) {
                    Text("Unable to load event")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        Task { await loadEventDetail() }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.ignoresSafeArea())
            } else if let detail = eventDetail ?? cachedDetail {
                EventView(event: detail)
                    .preferredColorScheme(.dark)
            } else {
                Text("Event not found")
                    .foregroundColor(.white.opacity(0.8))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.ignoresSafeArea())
            }
        }
        .task {
            if eventDetail == nil && cachedDetail == nil {
                await loadEventDetail()
            }
        }
    }
    
    private func loadEventDetail() async {
        guard let eventIdUInt64 = uuidToEventIdMap[eventId] else {
            await MainActor.run {
                errorMessage = "Event ID not found"
            }
            return
        }
        
        // Check cache first
        if let cached = eventDetailsCache[eventId] {
            await MainActor.run {
                eventDetail = cached
            }
            return
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let dto = try await EventService.shared.getEvent(by: eventIdUInt64)
            var eventIdMap: [UInt64: UUID] = [:]
            eventIdMap[eventIdUInt64] = eventId
            
            if let detail = mapEventDTOToEventDetail(dto, eventIdMap: &eventIdMap) {
                await MainActor.run {
                    eventDetail = detail
                    eventDetailsCache[eventId] = detail
                    isLoading = false
                }
            } else {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to map event data"
                }
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
}
