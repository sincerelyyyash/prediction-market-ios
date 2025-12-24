import SwiftUI

struct HomeView: View {
    @State private var searchText = ""
    @State private var selectedCategory: EventCategory?
    @State private var path: [UUID] = []
    @State private var events: [Event] = []
    @State private var bookmarkedEvents: [Event] = []
    @State private var forYouEvents: [Event] = []
    @State private var eventIdMap: [UInt64: UUID] = [:]
    @State private var uuidToEventIdMap: [UUID: UInt64] = [:]
    @State private var eventDetailsCache: [UUID: EventDetail] = [:]
    @State private var isLoading = false
    @State private var errorMessage: String?

    /// Bookmarks section: show bookmarked events, fallback to first 10 general events if empty
    private var bookmarksToShow: [Event] {
        let baseEvents = bookmarkedEvents.isEmpty 
            ? events.filter { !$0.isResolved }.prefix(10).map { $0 }
            : bookmarkedEvents
        return filterEvents(baseEvents)
    }

    /// For You section: show for-you events, fallback to first 5 general events if empty
    private var forYouToShow: [Event] {
        let baseEvents = forYouEvents.isEmpty 
            ? events.filter { !$0.isResolved }.prefix(5).map { $0 }
            : forYouEvents
        return filterEvents(baseEvents)
    }
    
    /// Filter events based on search text and category
    private func filterEvents(_ events: [Event]) -> [Event] {
        events.filter { event in
            let matchesCategory = selectedCategory == nil || event.category == selectedCategory
            let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            let matchesSearch = trimmed.isEmpty ||
                event.title.localizedCaseInsensitiveContains(trimmed) ||
                (event.description?.localizedCaseInsensitiveContains(trimmed) ?? false)
            return matchesCategory && matchesSearch
        }
    }

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
                        contentBody(geo: geo)
                    }
                }
            }
            .navigationDestination(for: UUID.self) { eventId in
                EventDetailView(
                    eventId: eventId,
                    cachedDetail: eventDetailsCache[eventId],
                    uuidToEventIdMap: uuidToEventIdMap,
                    eventDetailsCache: $eventDetailsCache
                )
                .transition(.slideFromTrailing)
            }
        }
        .task {
            await loadEvents()
        }
    }

    @ViewBuilder
    private func contentBody(geo: GeometryProxy) -> some View {
        if isLoading && events.isEmpty {
            FullScreenLoadingView(message: "Loading events...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage, events.isEmpty {
            VStack(spacing: 12) {
                Text("Unable to load events")
                    .font(.dmMonoMedium(size: 17))
                    .foregroundColor(AppColors.primaryText)
                Text(errorMessage)
                    .font(.dmMonoRegular(size: 15))
                    .foregroundColor(AppColors.secondaryText(opacity: 0.7))
                    .multilineTextAlignment(.center)
                Button("Try Again", action: { Task { await loadEvents() } })
                    .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Bookmarks")
                            .font(.dmMonoMedium(size: 20))
                            .foregroundColor(AppColors.primaryText)

                        if bookmarksToShow.isEmpty {
                            Text("No bookmarks yet")
                                .font(.dmMonoRegular(size: 14))
                                .foregroundColor(AppColors.secondaryText(opacity: 0.6))
                                .padding(.vertical, 12)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(bookmarksToShow) { event in
                                        EventCardView(
                                            event: event,
                                            yesAction: {},
                                            noAction: {}
                                        )
                                        .frame(width: max(260, geo.size.width * 0.72))
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            withAnimation(.slideTransition) {
                                                path.append(event.id)
                                            }
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("For You")
                            .font(.dmMonoMedium(size: 20))
                            .foregroundColor(AppColors.primaryText)

                        if forYouToShow.isEmpty {
                            Text("No recommendations yet")
                                .font(.dmMonoRegular(size: 14))
                                .foregroundColor(AppColors.secondaryText(opacity: 0.6))
                                .padding(.vertical, 12)
                        } else {
                            ForEach(forYouToShow) { event in
                                MarketCardView(
                                    content: MarketCardContent(event: event),
                                    handleOpen: {
                                        withAnimation(.slideTransition) {
                                            path.append(event.id)
                                        }
                                    }
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            PageIntroHeader(
                title: "Home",
                subtitle: "Stay on top of the markets you care about"
            )
            HomeHeaderView(
                searchText: $searchText,
                selectedCategory: $selectedCategory
            )
        }
    }

    private func loadEvents() async {
        guard !isLoading else { return }

        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        // 1) Fetch events first (drives main content)
        do {
            let remoteEvents = try await EventService.shared.getEvents()
            await MainActor.run {
                events = dedupeById(remoteEvents).compactMap { map(dto: $0) }
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
            }
            return
        }

        // 2) Fetch bookmarks and for-you in background; update sections when they land
        Task {
            let bookmarks = await loadBookmarksOrEmpty()
            await MainActor.run {
                bookmarkedEvents = dedupeById(bookmarks).compactMap { map(dto: $0) }
            }
        }

        Task {
            let forYou = await loadForYouOrEmpty()
            await MainActor.run {
                forYouEvents = dedupeById(forYou).compactMap { map(dto: $0) }
            }
        }
    }

    /// Load bookmarks, returning empty array on failure (non-blocking)
    private func loadBookmarksOrEmpty() async -> [EventDTO] {
        do {
            return try await EventService.shared.getBookmarkedEvents()
        } catch {
            return []
        }
    }

    /// Load for-you events, returning empty array on failure (non-blocking)
    private func loadForYouOrEmpty() async -> [EventDTO] {
        do {
            return try await EventService.shared.getForYouEvents()
        } catch {
            return []
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
            description: dto.description,
            imgUrl: dto.imgUrl
        )
    }

    private func dedupeById(_ dtos: [EventDTO]) -> [EventDTO] {
        var seen = Set<UInt64>()
        var result: [EventDTO] = []
        for dto in dtos {
            if seen.insert(dto.id).inserted {
                result.append(dto)
            }
        }
        return result
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
            AppColors.background.ignoresSafeArea()
            RadialGradient(
                gradient: Gradient(stops: [
                    .init(color: AppColors.gradientStart, location: 0.0),
                    .init(color: AppColors.gradientMiddle, location: 0.15),
                    .init(color: AppColors.gradientEnd, location: 0.4)
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
                FullScreenLoadingView(message: "Loading event details...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage {
                VStack(spacing: 12) {
                    Text("Unable to load event")
                        .font(.dmMonoMedium(size: 17))
                        .foregroundColor(AppColors.primaryText)
                    Text(errorMessage)
                        .font(.dmMonoRegular(size: 15))
                        .foregroundColor(AppColors.secondaryText(opacity: 0.7))
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        Task { await loadEventDetail() }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppColors.background.ignoresSafeArea())
            } else if let detail = eventDetail ?? cachedDetail {
                EventView(event: detail)
            } else {
                Text("Event not found")
                    .foregroundColor(AppColors.secondaryText(opacity: 0.8))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppColors.background.ignoresSafeArea())
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
}
