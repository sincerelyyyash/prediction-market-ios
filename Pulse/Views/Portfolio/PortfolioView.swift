import SwiftUI

// Dedicated loader for navigating from Portfolio to an event detail.
fileprivate struct PortfolioEventDetailView: View {
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
                        .font(.dmMonoMedium(size: 17))
                        .foregroundColor(.white)
                    Text(errorMessage)
                        .font(.dmMonoRegular(size: 15))
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
            await MainActor.run { errorMessage = "Event ID not found" }
            return
        }

        if let cached = eventDetailsCache[eventId] {
            eventDetail = cached
            return
        }

        await MainActor.run { isLoading = true }

        do {
            let dto = try await EventService.shared.getEvent(by: eventIdUInt64)
            var localMap = uuidToEventIdMap.reduce(into: [UInt64: UUID]()) { result, kv in
                result[kv.value] = kv.key
            }
            guard let detail = mapEventDTOToEventDetail(dto, eventIdMap: &localMap) else {
                throw APIError.decoding(NSError(domain: "EventDetail", code: -1))
            }
            await MainActor.run {
                eventDetail = detail
                eventDetailsCache[eventId] = detail
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct PortfolioView: View {
    enum PortfolioTab: String, CaseIterable, Identifiable {
        case positions = "Positions"
        case pending = "Pending Orders"
        case closed = "Closed Orders"
        var id: String { rawValue }
    }

    @State private var path: [UUID] = []
    @State private var selectedTab: PortfolioTab = .positions
    @State private var totalPnLValue: Double = 0
    @State private var totalPnLPercent: Double = 0
    @State private var totalBalance: Int64 = 0
    @State private var portfolioPositions: [PortfolioPosition] = []
    @State private var openOrders: [Order] = []
    @State private var orderHistory: [Order] = []
    @State private var marketMeta: [Int64: MarketMeta] = [:]
    @State private var eventIdMap: [UInt64: UUID] = [:]
    @State private var uuidToEventIdMap: [UUID: UInt64] = [:]
    @State private var eventDetailsCache: [UUID: EventDetail] = [:]
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var requiresAuth = false
    @StateObject private var authService = AuthService.shared

    private var pendingOrders: [Order] {
        openOrders.filter { !$0.isFilled }
    }

    private var closedOrders: [Order] {
        orderHistory.filter { $0.isFilled }
    }

    var body: some View {
        NavigationStack(path: $path) {
            GeometryReader { geo in
                ZStack {
                    backgroundGradient(for: geo)
                    contentBody
                }
            }
            .navigationDestination(for: UUID.self) { eventId in
                PortfolioEventDetailView(
                    eventId: eventId,
                    cachedDetail: eventDetailsCache[eventId],
                    uuidToEventIdMap: uuidToEventIdMap,
                    eventDetailsCache: $eventDetailsCache
                )
            }
        }
        .task {
            await loadPortfolioData()
        }
        .refreshable {
            await loadPortfolioData()
        }
    }

    private var tabFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                CategoryChipView(
                    title: "Positions",
                    icon: "briefcase.fill",
                    isSelected: selectedTab == .positions
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                        selectedTab = .positions
                    }
                }
                CategoryChipView(
                    title: "Pending",
                    icon: "clock.fill",
                    isSelected: selectedTab == .pending
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                        selectedTab = .pending
                    }
                }
                CategoryChipView(
                    title: "Closed",
                    icon: "checkmark.seal.fill",
                    isSelected: selectedTab == .closed
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                        selectedTab = .closed
                    }
                }
            }
            .padding(.vertical, 6)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            PageIntroHeader(
                title: "Portfolio",
                subtitle: "Track your PnL, positions, and order history"
            )

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Total PnL")
                        .font(.dmMonoRegular(size: 15))
                        .foregroundColor(.white.opacity(0.7))
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text(formattedCurrency(totalPnLValue))
                            .font(.dmMonoMedium(size: 28))
                            .foregroundColor(totalPnLValue >= 0 ? Color.green : Color.red)
                        Text("(\(formattedPercent(totalPnLPercent)))")
                            .font(.dmMonoMedium(size: 17))
                            .foregroundColor(totalPnLPercent >= 0 ? Color.green.opacity(0.9) : Color.red.opacity(0.9))
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.08))
                        )
                )
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Total Profit and Loss")
                .accessibilityValue("\(formattedCurrency(totalPnLValue)) and \(formattedPercent(totalPnLPercent))")
            }
        }
    }

    private func formattedCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }

    private func formattedPercent(_ value: Double) -> String {
        String(format: "%.1f%%", value)
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

    @ViewBuilder
    private var contentBody: some View {
        if isLoading && portfolioPositions.isEmpty {
            ProgressView("Loading portfolio...")
                .progressViewStyle(.circular)
                .tint(.white)
        } else if requiresAuth {
            VStack(spacing: 20) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 80, height: 80)
                    Image(systemName: "chart.pie.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.bottom, 4)
                
                // Title
                Text("Sign in to view your positions")
                    .font(.dmMonoMedium(size: 20))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                // Subtitle
                Text("Track your PnL, open positions, and order history all in one place.")
                    .font(.dmMonoRegular(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                // Sign In Button
                Button {
                    authService.signOut()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Sign In")
                            .font(.dmMonoMedium(size: 16))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 48)
                .padding(.top, 8)
                .accessibilityLabel("Sign In")
                .accessibilityHint("Redirects to the sign in screen")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage, portfolioPositions.isEmpty && pendingOrders.isEmpty && closedOrders.isEmpty {
            VStack(spacing: 12) {
                Text("Unable to load portfolio")
                    .font(.dmMonoMedium(size: 17))
                    .foregroundColor(.white)
                Text(errorMessage)
                    .font(.dmMonoRegular(size: 15))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                Button("Retry") {
                    Task { await loadPortfolioData() }
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
            }
        } else {
            VStack(spacing: 0) {
                Spacer(minLength: 8)

                header
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)

                tabFilters
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)

                ScrollView {
                    LazyVStack(spacing: 12) {
                        switch selectedTab {
                        case .positions:
                            if portfolioPositions.isEmpty {
                                emptyState(message: "No open positions yet.")
                            } else {
                                ForEach(portfolioPositions) { position in
                                    let meta = marketMeta[position.marketId]
                                    let name = meta?.displayName ?? "Market \(position.marketId)"
                                    PortfolioPositionRow(
                                        position: position,
                                        marketName: name,
                                        marketPrice: position.marketPrice,
                                        marketValue: position.value
                                    )
                                    .onTapGesture {
                                        if let eventUUID = meta?.eventUUID {
                                            path.append(eventUUID)
                                        }
                                    }
                                }
                            }
                        case .pending:
                            if pendingOrders.isEmpty {
                                emptyState(message: "No pending orders.")
                            } else {
                                ForEach(pendingOrders) { order in
                                    OrderRow(order: order)
                                }
                            }
                        case .closed:
                            if closedOrders.isEmpty {
                                emptyState(message: "No closed orders.")
                            } else {
                                ForEach(closedOrders) { order in
                                    OrderRow(order: order)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
        }
    }

    private func emptyState(message: String) -> some View {
        Text(message)
            .font(.dmMonoRegular(size: 13))
            .foregroundColor(.white.opacity(0.7))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
    }

    private func loadPortfolioData() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            requiresAuth = false
        }

        // Check auth state first
        await authService.restoreSessionIfNeeded()
        guard authService.session?.user.id != nil else {
            await MainActor.run {
                isLoading = false
                requiresAuth = true
            }
            return
        }

        // Fast path: portfolio only
        do {
            let portfolio = try await PositionService.shared.getPortfolio()
            await MainActor.run {
                self.portfolioPositions = portfolio.positions ?? []
                applyPnl(portfolio)
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
            }
            return
        }

        // Background: open orders
        Task {
            if let pending = try? await OrderService.shared.getOpenOrders() {
                await MainActor.run { self.openOrders = pending }
            }
        }

        // Background: history
        Task {
            if let history = try? await OrderService.shared.getOrderHistory() {
                await MainActor.run { self.orderHistory = history }
            }
        }

        // Background: events for naming/tap-through
        Task {
            if let events = try? await EventService.shared.getEvents() {
                var updatedEventIdMap = eventIdMap
                let meta = buildMarketMetaLookup(events, eventIdMap: &updatedEventIdMap)
                await MainActor.run {
                    self.marketMeta = meta.lookup
                    self.eventIdMap = updatedEventIdMap
                    self.uuidToEventIdMap = updatedEventIdMap.reduce(into: [:]) { result, kv in
                        result[kv.value] = kv.key
                    }
                }
            }
        }
    }

    private func applyPnl(_ portfolio: PortfolioSnapshot) {
        if let pnl = portfolio.pnl {
            totalPnLValue = Double(pnl)
        } else {
            totalPnLValue = 0
        }
        if let balance = portfolio.balance, balance != 0 {
            let balanceValue = Double(balance)
            totalPnLPercent = (totalPnLValue / balanceValue) * 100.0
        } else if let totalValue = portfolio.totalValue, totalValue != 0 {
            let totalValueDouble = Double(totalValue)
            totalPnLPercent = (totalPnLValue / totalValueDouble) * 100.0
        } else {
            totalPnLPercent = 0
        }

        totalBalance = portfolio.balance ?? 0
    }

    private struct MarketMeta {
        let displayName: String
        let eventUUID: UUID?
    }

    private func buildMarketMetaLookup(
        _ events: [EventDTO],
        eventIdMap: inout [UInt64: UUID]
    ) -> (lookup: [Int64: MarketMeta], eventIdMap: [UInt64: UUID]) {
        var lookup: [Int64: MarketMeta] = [:]

        for event in events {
            let eventUUID = eventIdMap[event.id] ?? UUID()
            eventIdMap[event.id] = eventUUID
            let eventTitle = event.title
            let outcomes = event.outcomes ?? []

            for outcome in outcomes {
                let outcomeName = outcome.name.isEmpty ? eventTitle : outcome.name
                let base = "\(eventTitle) – \(outcomeName)"

                if let yesId = outcome.yesMarketId {
                    lookup[Int64(yesId)] = MarketMeta(displayName: "\(base) (Yes)", eventUUID: eventUUID)
                }
                if let noId = outcome.noMarketId {
                    lookup[Int64(noId)] = MarketMeta(displayName: "\(base) (No)", eventUUID: eventUUID)
                }

                if let markets = outcome.markets {
                    for market in markets {
                        let sideLabel: String
                        switch market.side?.lowercased() {
                        case "yes": sideLabel = "Yes"
                        case "no": sideLabel = "No"
                        default: continue
                        }
                        lookup[Int64(market.identifier)] = MarketMeta(
                            displayName: "\(base) (\(sideLabel))",
                            eventUUID: eventUUID
                        )
                    }
                }
            }
        }

        return (lookup, eventIdMap)
    }
}

// MARK: - Rows

private struct PortfolioPositionRow: View {
    let position: PortfolioPosition
    let marketName: String
    let marketPrice: Int64?
    let marketValue: Int64?

    private var formattedValue: String {
        guard let value = marketValue else { return "--" }
        return currency(value)
    }

    private var formattedPrice: String {
        guard let price = marketPrice else { return "--" }
        return "\(price)¢"
    }

    private func currency(_ value: Int64) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: value)) ?? "$\(value)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(marketName)
                    .font(.dmMonoMedium(size: 17))
                    .foregroundColor(.white)
                Spacer()
                Text("Qty: \(position.quantity)")
                    .font(.dmMonoMedium(size: 17))
                    .foregroundColor(.white)
            }
            HStack(spacing: 10) {
                statChip(title: "Price", value: formattedPrice)
                statChip(title: "Value", value: formattedValue)
                Spacer()
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.08))
                )
        )
    }

    private func statChip(title: String, value: String) -> some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.dmMonoRegular(size: 12))
                .foregroundColor(.white.opacity(0.7))
            Text(value)
                .font(.dmMonoMedium(size: 12))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            Capsule(style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
    }
}

private struct OrderRow: View {
    let order: Order

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text(order.side.rawValue.uppercased())
                    .font(.dmMonoMedium(size: 17))
                    .foregroundColor(.white)
                Spacer()
                statusBadge
            }
            Text("Market \(order.marketId)")
                .font(.dmMonoRegular(size: 15))
                .foregroundColor(.white.opacity(0.65))
            HStack(spacing: 10) {
                statChip(title: "Qty", value: "\(order.originalQuantity)")
                statChip(title: "Price", value: "\(order.price)")
                statChip(title: "Status", value: order.status ?? "--")
                Spacer()
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.08))
                )
        )
    }

    private var statusBadge: some View {
        Text(order.status ?? "Pending")
            .font(.dmMonoRegular(size: 12))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule(style: .continuous)
                    .fill(badgeColor.opacity(0.18))
            )
            .foregroundColor(badgeColor)
    }

    private var badgeColor: Color {
        guard let status = order.status?.lowercased() else { return .yellow }
        switch status {
        case "filled":
            return .green
        case "cancelled":
            return .red
        default:
            return .yellow
        }
    }

    private func statChip(title: String, value: String) -> some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.dmMonoRegular(size: 12))
                .foregroundColor(.white.opacity(0.7))
            Text(value)
                .font(.dmMonoMedium(size: 12))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            Capsule(style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
    }
}

#Preview {
    PortfolioView()
        .preferredColorScheme(.dark)
}

