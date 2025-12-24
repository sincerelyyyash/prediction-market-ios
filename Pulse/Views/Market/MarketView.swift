import SwiftUI

struct MarketView: View {
    @State private var searchText = ""
    @State private var selectedCategory: EventCategory?
    @State private var path: [UUID] = []
    @State private var events: [EventDetail] = []
    @State private var eventIdMap: [UInt64: UUID] = [:]
    @State private var uuidToEventIdMap: [UUID: UInt64] = [:]
    @State private var eventDetailsCache: [UUID: EventDetail] = [:]
    @State private var isLoading = false
    @State private var errorMessage: String?

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
                        contentBody
                    }
                }
            }
            .navigationDestination(for: UUID.self) { id in
                MarketEventDetailView(
                    eventId: id,
                    cachedDetail: eventDetailsCache[id] ?? filteredMarkets.first(where: { $0.id == id }),
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
    
    @ViewBuilder
    private var contentBody: some View {
        if isLoading {
            FullScreenLoadingView(message: "Loading markets...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage {
            VStack(spacing: 12) {
                Text("Unable to load markets")
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
                    ForEach(filteredMarkets) { detail in
                        MarketCardView(
                            content: MarketCardContent(detail: detail),
                            handleOpen: {
                                withAnimation(.slideTransition) {
                                    path.append(detail.id)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
    }

    // Filters now operate on the fetched events
    private var filteredMarkets: [EventDetail] {
        events.filter { detail in
            let matchesCategory = selectedCategory == nil || detail.category == selectedCategory
            let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            let matchesSearch = trimmed.isEmpty ||
                detail.title.localizedCaseInsensitiveContains(trimmed) ||
                (detail.subtitle?.localizedCaseInsensitiveContains(trimmed) ?? false)
            return matchesCategory && matchesSearch
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
            var mappedEvents: [EventDetail] = []
            for dto in remoteEvents {
                if let detail = mapEventDTOToEventDetail(dto, eventIdMap: &eventIdMap) {
                    mappedEvents.append(detail)
                    uuidToEventIdMap[detail.id] = dto.id
                    eventDetailsCache[detail.id] = detail
                }
            }
            await MainActor.run {
                events = mappedEvents
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
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

// MARK: - MarketEventDetailView Helper

private struct MarketEventDetailView: View {
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
                Text("Market not found")
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
    MarketView()
}
