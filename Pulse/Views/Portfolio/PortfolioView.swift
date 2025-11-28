import SwiftUI

struct PortfolioView: View {
    enum PortfolioTab: String, CaseIterable, Identifiable {
        case positions = "Positions"
        case pending = "Pending Orders"
        case closed = "Closed Orders"
        var id: String { rawValue }
    }

    @State private var selectedTab: PortfolioTab = .positions

    // Demo PnL values (header)
    @State private var totalPnLValue: Double = 1234.56
    @State private var totalPnLPercent: Double = 12.3

    // Demo data based on market-style Yes/No outcomes
    private var demoPositions: [PortfolioPosition] {
        guard let event = Constants.placeholderEventDetails.first else { return [] }
        let outcomes = event.outcomes
        var items: [PortfolioPosition] = []
        if let first = outcomes.first {
            items.append(
                PortfolioPosition(
                    eventTitle: event.title,
                    outcomeName: first.name,
                    side: .yes,
                    qty: 120,
                    avgPrice: 0.52,
                    markPrice: first.yes.price
                )
            )
        }
        if outcomes.count > 1 {
            let second = outcomes[1]
            items.append(
                PortfolioPosition(
                    eventTitle: event.title,
                    outcomeName: second.name,
                    side: .no,
                    qty: 80,
                    avgPrice: 0.65,
                    markPrice: second.no.price
                )
            )
        }
        if outcomes.count > 2 {
            let third = outcomes[2]
            items.append(
                PortfolioPosition(
                    eventTitle: event.title,
                    outcomeName: third.name,
                    side: .yes,
                    qty: 60,
                    avgPrice: 0.40,
                    markPrice: third.yes.price
                )
            )
        }
        return items
    }

    private var demoPendingOrders: [PortfolioOrder] {
        guard let event = Constants.placeholderEventDetails.first else { return [] }
        let outcomes = event.outcomes
        var items: [PortfolioOrder] = []
        if let first = outcomes.first {
            items.append(
                PortfolioOrder(
                    eventTitle: event.title,
                    outcomeName: first.name,
                    side: .yes,
                    qty: 50,
                    limitPrice: (first.yes.bestBid + first.yes.bestAsk) / 2.0,
                    status: .pending
                )
            )
        }
        if outcomes.count > 1 {
            let second = outcomes[1]
            items.append(
                PortfolioOrder(
                    eventTitle: event.title,
                    outcomeName: second.name,
                    side: .no,
                    qty: 30,
                    limitPrice: (second.no.bestBid + second.no.bestAsk) / 2.0,
                    status: .pending
                )
            )
        }
        return items
    }

    private var demoClosedOrders: [PortfolioOrder] {
        guard let event = Constants.placeholderEventDetails.first else { return [] }
        let outcomes = event.outcomes
        var items: [PortfolioOrder] = []
        if outcomes.count > 1 {
            let second = outcomes[1]
            items.append(
                PortfolioOrder(
                    eventTitle: event.title,
                    outcomeName: second.name,
                    side: .yes,
                    qty: 40,
                    limitPrice: second.yes.price,
                    status: .filled
                )
            )
        }
        if let first = outcomes.first {
            items.append(
                PortfolioOrder(
                    eventTitle: event.title,
                    outcomeName: first.name,
                    side: .no,
                    qty: 100,
                    limitPrice: first.no.price,
                    status: .filled
                )
            )
        }
        return items
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                backgroundGradient(for: geo)
                VStack(spacing: 0) {
                    Spacer(minLength: 8)

                    header
                        .padding(.horizontal, 16)
                        .padding(.bottom, 10)

                    // Market-style filter chips
                    tabFilters
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)

                    ScrollView {
                        LazyVStack(spacing: 12) {
                            switch selectedTab {
                            case .positions:
                                ForEach(demoPositions) { position in
                                    PositionRow(position: position)
                                }
                            case .pending:
                                ForEach(demoPendingOrders) { order in
                                    OrderRow(order: order)
                                }
                            case .closed:
                                ForEach(demoClosedOrders) { order in
                                    OrderRow(order: order)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                }
            }
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
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white.opacity(0.7))
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text(formattedCurrency(totalPnLValue))
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(totalPnLValue >= 0 ? Color.green : Color.red)
                        Text("(\(formattedPercent(totalPnLPercent)))")
                            .font(.headline.weight(.semibold))
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
}

// MARK: - Models

private struct PortfolioPosition: Identifiable {
    let id = UUID()
    let eventTitle: String
    let outcomeName: String
    let side: MarketSideType
    let qty: Int
    let avgPrice: Double   // 0...1
    let markPrice: Double  // 0...1
}

private enum OrderStatus: String {
    case pending = "Pending"
    case filled = "Filled"
    case cancelled = "Cancelled"
}

private struct PortfolioOrder: Identifiable {
    let id = UUID()
    let eventTitle: String
    let outcomeName: String
    let side: MarketSideType
    let qty: Int
    let limitPrice: Double // 0...1
    let status: OrderStatus
}

// MARK: - Rows

private struct PositionRow: View {
    let position: PortfolioPosition

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                sideChip(position.side)
                Text(position.outcomeName)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white)
                Spacer()
                Text(pnlString(pnlValue()))
                    .font(.headline.weight(.semibold))
                    .foregroundColor(pnlValue() >= 0 ? .green : .red)
            }
            Text(position.eventTitle)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.65))
            HStack(spacing: 10) {
                statChip(title: "Qty", value: "\(position.qty)")
                statChip(title: "Avg", value: formattedProb(position.avgPrice))
                statChip(title: "Mark", value: formattedProb(position.markPrice))
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

    private func pnlValue() -> Double {
        let diff = position.side == .yes ? (position.markPrice - position.avgPrice) : (position.avgPrice - position.markPrice)
        return diff * Double(position.qty)
    }
    private func pnlString(_ v: Double) -> String {
        let sign = v >= 0 ? "+" : ""
        return "\(sign)$\(String(format: "%.2f", abs(v)))"
    }
    private func formattedProb(_ p: Double) -> String {
        String(format: "%.2f", p)
    }
    private func sideChip(_ side: MarketSideType) -> some View {
        Text(side.rawValue.uppercased())
            .font(.caption.weight(.bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule(style: .continuous)
                    .fill(side.color.opacity(0.22))
            )
            .foregroundColor(side.color)
    }
    private func statChip(title: String, value: String) -> some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundColor(.white.opacity(0.7))
            Text(value)
                .font(.caption.weight(.bold))
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
    let order: PortfolioOrder

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                sideChip(order.side)
                Text(order.outcomeName)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white)
                Spacer()
                statusBadge
            }
            Text(order.eventTitle)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.65))
            HStack(spacing: 10) {
                statChip(title: "Qty", value: "\(order.qty)")
                statChip(title: "Limit", value: formattedProb(order.limitPrice))
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
        Text(order.status.rawValue)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule(style: .continuous)
                    .fill(badgeColor.opacity(0.18))
            )
            .foregroundColor(badgeColor)
    }

    private var badgeColor: Color {
        switch order.status {
        case .pending: return .yellow
        case .filled: return .green
        case .cancelled: return .red
        }
    }

    private func formattedProb(_ p: Double) -> String {
        String(format: "%.2f", p)
    }
    private func sideChip(_ side: MarketSideType) -> some View {
        Text(side.rawValue.uppercased())
            .font(.caption.weight(.bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule(style: .continuous)
                    .fill(side.color.opacity(0.22))
            )
            .foregroundColor(side.color)
    }
    private func statChip(title: String, value: String) -> some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundColor(.white.opacity(0.7))
            Text(value)
                .font(.caption.weight(.bold))
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

