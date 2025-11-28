import SwiftUI

struct OrderbookView: View {
    let eventID: UUID
    let outcome: OutcomeMarket

    @State private var selectedSide: MarketSideType = .yes
    @State private var levelCount = 10

    private var topOfBookBid: Double {
        selectedSide == .yes ? outcome.yes.bestBid : outcome.no.bestBid
    }

    private var topOfBookAsk: Double {
        selectedSide == .yes ? outcome.yes.bestAsk : outcome.no.bestAsk
    }

    private var bookFromConstants: Orderbook? {
        Constants.placeholderOrderbooks[eventID]?[outcome.id]?[selectedSide]
    }

    private var book: Orderbook {
        if let book = bookFromConstants {
            return expand(book: book, to: levelCount)
        }
        return fallbackLadder(steps: levelCount)
    }

    var body: some View {
        VStack(spacing: 16) {
            Color.clear.frame(height: 8)
            header
            levelSelector
            ladderHeader
            ladderBody
            actionButtons
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color.black)
        .ignoresSafeArea()
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(outcome.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Text("Orderbook")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                Text("Side")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                Picker("", selection: $selectedSide) {
                    Text("Yes").tag(MarketSideType.yes)
                    Text("No").tag(MarketSideType.no)
                }
                .pickerStyle(.segmented)
                .frame(width: 180)
            }
        }
    }

    private var levelSelector: some View {
        HStack(spacing: 8) {
            Text("Levels")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.75))
            levelButton(10)
            levelButton(20)
            levelButton(50)
            Spacer()
        }
    }

    private var ladderHeader: some View {
        HStack {
            Text("Bids (Qty)")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.green)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Price")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white.opacity(0.85))
                .frame(width: 70)
            Text("Asks (Qty)")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }

    private var ladderBody: some View {
        let bids = book.bids
        let asks = book.asks
        let maxQty = max(bids.map(\.size).max() ?? 1, asks.map(\.size).max() ?? 1)

        return VStack(spacing: 4) {
            ForEach(0..<max(bids.count, asks.count), id: \.self) { index in
                let bid = index < bids.count ? bids[index] : nil
                let ask = index < asks.count ? asks[index] : nil
                HStack(spacing: 8) {
                    bidView(bid, maxQty: maxQty)
                    Text(centerPriceText(bid: bid?.price, ask: ask?.price))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 70)
                    askView(ask, maxQty: maxQty)
                }
            }
        }
        .padding(8)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func bidView(_ bid: OrderbookLevel?, maxQty: Double) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.green.opacity(0.10))
                .frame(height: 28)
                .opacity(bid == nil ? 0 : 1)
            if let bid {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.green.opacity(0.25))
                    .frame(width: depthWidth(bid.size, maxQty: maxQty), height: 28)
                Text(shortSize(bid.size))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func askView(_ ask: OrderbookLevel?, maxQty: Double) -> some View {
        ZStack(alignment: .trailing) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.red.opacity(0.10))
                .frame(height: 28)
                .opacity(ask == nil ? 0 : 1)
            if let ask {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.red.opacity(0.25))
                    .frame(width: depthWidth(ask.size, maxQty: maxQty), height: 28)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                Text(shortSize(ask.size))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.red)
                    .padding(.horizontal, 8)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                // hook buy action
            } label: {
                HStack {
                    Image(systemName: "cart.fill.badge.plus")
                        .font(.system(size: 14, weight: .bold))
                    Text(selectedSide == .yes ? "Buy Yes" : "Buy No")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(selectedSide == .yes ? .black : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(selectedSide == .yes ? Color.green : Color.red)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)

            Button {
                // hook sell action
            } label: {
                HStack {
                    Image(systemName: "arrow.uturn.down")
                        .font(.system(size: 14, weight: .bold))
                    Text("Sell")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white.opacity(0.14), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }

    private func levelButton(_ count: Int) -> some View {
        Button {
            levelCount = count
        } label: {
            Text("\(count)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(count == levelCount ? Color.white.opacity(0.16) : Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.white.opacity(count == levelCount ? 0.0 : 0.14), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func fallbackLadder(steps: Int) -> Orderbook {
        let tick = 0.01
        let baseSize: Double = 1_000
        let bids: [OrderbookLevel] = (0..<steps).map { index in
            let price = max(0.0, topOfBookBid - Double(index) * tick)
            let size = baseSize * (1.0 + Double(index) * 0.25)
            return OrderbookLevel(price: price, size: size)
        }
        let asks: [OrderbookLevel] = (0..<steps).map { index in
            let price = min(1.0, topOfBookAsk + Double(index) * tick)
            let size = baseSize * (1.0 + Double(index) * 0.25)
            return OrderbookLevel(price: price, size: size)
        }
        return Orderbook(bids: bids, asks: asks)
    }

    private func expand(book: Orderbook, to levels: Int) -> Orderbook {
        if book.bids.count >= levels && book.asks.count >= levels {
            return book
        }
        let tick = 0.01
        var bids = book.bids
        var asks = book.asks

        if let lastBid = bids.last {
            while bids.count < levels {
                let next = OrderbookLevel(
                    price: max(0.0, lastBid.price - tick * Double(bids.count - book.bids.count + 1)),
                    size: lastBid.size * (1.0 + 0.2 * Double(bids.count - book.bids.count + 1))
                )
                bids.append(next)
            }
        }

        if let lastAsk = asks.last {
            while asks.count < levels {
                let next = OrderbookLevel(
                    price: min(1.0, lastAsk.price + tick * Double(asks.count - book.asks.count + 1)),
                    size: lastAsk.size * (1.0 + 0.2 * Double(asks.count - book.asks.count + 1))
                )
                asks.append(next)
            }
        }
        return Orderbook(
            bids: Array(bids.prefix(levels)),
            asks: Array(asks.prefix(levels))
        )
    }

    private func depthWidth(_ size: Double, maxQty: Double) -> CGFloat {
        let percentage = max(0, min(1, size / maxQty))
        return max(8, CGFloat(percentage) * 140)
    }

    private func centerPriceText(bid: Double?, ask: Double?) -> String {
        if let bid, let ask {
            return percent((bid + ask) / 2.0)
        }
        if let bid {
            return percent(bid)
        }
        if let ask {
            return percent(ask)
        }
        return "--"
    }

    private func percent(_ value: Double) -> String {
        "\(Int((value * 100).rounded()))%"
    }

    private func shortSize(_ value: Double) -> String {
        if value >= 1_000_000 {
            return String(format: "%.1fM", value / 1_000_000)
        }
        if value >= 1_000 {
            return String(format: "%.1fk", value / 1_000)
        }
        return String(Int(value))
    }
}

