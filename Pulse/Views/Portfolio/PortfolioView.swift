import SwiftUI

struct PortfolioView: View {
    enum PortfolioTab: String, CaseIterable, Identifiable {
        case positions = "Positions"
        case pending = "Pending Orders"
        case closed = "Closed Orders"
        var id: String { rawValue }
    }

    @State private var selectedTab: PortfolioTab = .positions
    @State private var totalPnLValue: Double = 0
    @State private var totalPnLPercent: Double = 0
    @State private var totalBalance: Int64 = 0
    @State private var portfolioPositions: [PortfolioPosition] = []
    @State private var openOrders: [Order] = []
    @State private var orderHistory: [Order] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    private var pendingOrders: [Order] {
        openOrders.filter { !$0.isFilled }
    }

    private var closedOrders: [Order] {
        orderHistory.filter { $0.isFilled }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                backgroundGradient(for: geo)
                contentBody
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
        if isLoading {
            ProgressView("Loading portfolio...")
                .progressViewStyle(.circular)
                .tint(.white)
        } else if let errorMessage {
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
                .tint(.white)
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
                                    PortfolioPositionRow(position: position)
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
        }

        do {
            async let portfolioTask = PositionService.shared.getPortfolio()
            async let pendingTask = OrderService.shared.getOpenOrders()
            async let historyTask = OrderService.shared.getOrderHistory()
            let (portfolio, pending, history) = try await (portfolioTask, pendingTask, historyTask)
            await MainActor.run {
                self.portfolioPositions = portfolio.positions ?? []
                self.openOrders = pending
                self.orderHistory = history
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
                isLoading = false
            }
        } catch {
            if let apiError = error as? APIError {
                if case let .server(_, message) = apiError,
                   let message,
                   message.localizedCaseInsensitiveContains("failed to get balance"),
                   message.localizedCaseInsensitiveContains("user not found") {
                    await MainActor.run {
                        portfolioPositions = []
                        openOrders = []
                        orderHistory = []
                        totalPnLValue = 0
                        totalPnLPercent = 0
                        totalBalance = 0
                        isLoading = false
                        errorMessage = nil
                    }
                    return
                }
            }
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - Rows

private struct PortfolioPositionRow: View {
    let position: PortfolioPosition

    private var formattedValue: String {
        guard let value = position.value else { return "--" }
        return "$\(value)"
    }

    private var formattedPrice: String {
        guard let price = position.marketPrice else { return "--" }
        return "\(price)¢"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("Market \(position.marketId)")
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

