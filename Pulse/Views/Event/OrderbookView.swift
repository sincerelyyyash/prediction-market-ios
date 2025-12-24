import SwiftUI

struct OrderbookView: View {
    let eventID: UUID
    let outcome: OutcomeMarket

    @State private var selectedSide: MarketSideType
    @State private var levelCount = 10
    @State private var orderbooksBySide: [MarketSideType: DemoOrderbook] = [:]
    @State private var isLoading = false
    @State private var hasLoadedOnce = false
    @State private var orderbookErrorMessage: String?
    @State private var ticketConfig: OrderTicketConfig?
    
    enum ViewState {
        case orderbook
        case split
        case merge
    }
    @State private var currentView: ViewState = .orderbook
    @State private var splitAmountText = ""
    @State private var isSubmittingAdvanced = false
    @State private var advancedErrorMessage: String?
    @State private var advancedSuccessMessage: String?
    @State private var showAdvancedAlert = false
    @State private var advancedAlertMessage: String?
    @State private var orderType: OrderType = .limit
    @State private var priceText: String = ""
    @State private var quantityText: String = "10"
    @State private var isSubmittingOrder = false
    @State private var orderErrorMessage: String?
    @State private var isBuyOrder: Bool = true

    init(
        eventID: UUID,
        outcome: OutcomeMarket,
        initialSide: MarketSideType = .yes
    ) {
        self.eventID = eventID
        self.outcome = outcome
        _selectedSide = State(initialValue: initialSide)
        let initialPrice = initialSide == .yes ? outcome.yes.bestAsk : outcome.no.bestAsk
        _priceText = State(initialValue: String(Int((initialPrice * 100).rounded())))
        _quantityText = State(initialValue: "10")
        _orderType = State(initialValue: .limit)
    }

    private func marketId(for side: MarketSideType) -> UInt64? {
        side == .yes ? outcome.yes.marketId : outcome.no.marketId
    }

    private var topOfBookBid: Double {
        selectedSide == .yes ? outcome.yes.bestBid : outcome.no.bestBid
    }

    private var topOfBookAsk: Double {
        selectedSide == .yes ? outcome.yes.bestAsk : outcome.no.bestAsk
    }

    private var book: DemoOrderbook? {
        guard let fetchedBook = orderbooksBySide[selectedSide] else {
            return nil
        }
        return expand(book: fetchedBook, to: levelCount)
    }
    
    private var hasBothMarkets: Bool {
        outcome.yes.marketId != nil && outcome.no.marketId != nil
    }

    var body: some View {
        VStack(spacing: 16) {
            Color.clear.frame(height: 8)
            
            ZStack {
                if currentView == .orderbook {
                    orderbookContent
                        .transition(.move(edge: .leading).combined(with: .opacity))
                } else if currentView == .split {
                    splitContent
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                } else if currentView == .merge {
                    mergeContent
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: currentView)
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity, alignment: .top)
        .background(AppColors.background)
        .ignoresSafeArea()
        .task {
            await loadAllOrderbooks(isInitial: true)
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 10_000_000_000)
                await loadAllOrderbooks(isInitial: false)
            }
        }
    }
    
    private var orderbookContent: some View {
        VStack(spacing: 16) {
            header
            levelSelector
            
            if isLoading && !hasLoadedOnce {
                LoadingView(message: "Loading orderbook...", size: .medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else {
                ladderHeader
                ladderBody
            }
            
            actionButtons
        }
    }
    
    private func loadAllOrderbooks(isInitial: Bool) async {
        let sides: [MarketSideType] = [.yes, .no]

        await MainActor.run {
            if isInitial {
                isLoading = true
                advancedErrorMessage = nil
                advancedSuccessMessage = nil
                orderbookErrorMessage = nil
            }
        }

        for side in sides {
            guard let marketId = marketId(for: side) else {
                continue
            }

            do {
                let snapshot = try await OrderbookService.shared.getOrderbook(for: marketId)
                let mappedBook = mapOrderbookSnapshotToDemoOrderbook(snapshot)
                await MainActor.run {
                    orderbooksBySide[side] = mappedBook
                    orderbookErrorMessage = nil
                }
            } catch {
                await MainActor.run {
                    orderbookErrorMessage = "Orderbook unavailable for this market."
                }
            }
        }

        await MainActor.run {
            if isInitial {
                isLoading = false
                hasLoadedOnce = true
            }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(outcome.name)
                    .font(.dmMonoMedium(size: 18))
                    .foregroundColor(AppColors.primaryText)
                Text("Orderbook")
                    .font(.dmMonoRegular(size: 12))
                    .foregroundColor(AppColors.secondaryText(opacity: 0.7))
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                Text("Side")
                    .font(.dmMonoRegular(size: 11))
                    .foregroundColor(AppColors.secondaryText(opacity: 0.7))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                Picker("", selection: $selectedSide) {
                    Text("Yes").tag(MarketSideType.yes)
                    Text("No").tag(MarketSideType.no)
                }
                .pickerStyle(.segmented)
                .frame(width: 180)
                .onChange(of: selectedSide) { _, _ in
                    if orderType == .limit && !priceText.isEmpty {
                        let initialPrice = isBuyOrder 
                            ? (selectedSide == .yes ? outcome.yes.bestAsk : outcome.no.bestAsk)
                            : (selectedSide == .yes ? outcome.yes.bestBid : outcome.no.bestBid)
                        priceText = String(Int((initialPrice * 100).rounded()))
                    }
                }
            }
        }
    }
    
    private var splitHeader: some View {
        HStack {
            Button {
                withAnimation {
                    currentView = .orderbook
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.dmMonoMedium(size: 14))
                    Text("Back")
                        .font(.dmMonoMedium(size: 15))
                }
                .foregroundColor(AppColors.secondaryText(opacity: 0.8))
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(outcome.name)
                    .font(.dmMonoMedium(size: 18))
                    .foregroundColor(AppColors.primaryText)
                Text("Split Position")
                    .font(.dmMonoRegular(size: 12))
                    .foregroundColor(AppColors.secondaryText(opacity: 0.7))
            }
        }
    }
    
    private var mergeHeader: some View {
        HStack {
            Button {
                withAnimation {
                    currentView = .orderbook
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.dmMonoMedium(size: 14))
                    Text("Back")
                        .font(.dmMonoMedium(size: 15))
                }
                .foregroundColor(AppColors.secondaryText(opacity: 0.8))
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(outcome.name)
                    .font(.dmMonoMedium(size: 18))
                    .foregroundColor(AppColors.primaryText)
                Text("Merge Positions")
                    .font(.dmMonoRegular(size: 12))
                    .foregroundColor(AppColors.secondaryText(opacity: 0.7))
            }
        }
    }

    private var levelSelector: some View {
        HStack(spacing: 8) {
            Text("Levels")
                .font(.dmMonoRegular(size: 12))
                .foregroundColor(AppColors.secondaryText(opacity: 0.75))
            levelButton(10)
            levelButton(20)
            levelButton(50)
            Spacer()
        }
    }

    private var ladderHeader: some View {
        HStack {
            Text("Bids (Qty)")
                .font(.dmMonoRegular(size: 11))
                .foregroundColor(.green)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Price")
                .font(.dmMonoRegular(size: 11))
                .foregroundColor(AppColors.secondaryText(opacity: 0.85))
                .frame(width: 70)
            Text("Asks (Qty)")
                .font(.dmMonoRegular(size: 11))
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 6)
        .background(AppColors.cardBackground(opacity: 0.06))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(AppColors.border(opacity: 0.12), lineWidth: 1)
        )
    }

    private var ladderBody: some View {
        let bids = book?.bids ?? []
        let asks = book?.asks ?? []
        let maxQty = max(bids.map(\.size).max() ?? 1, asks.map(\.size).max() ?? 1)
        let hasDepth = !(bids.isEmpty && asks.isEmpty)

        return VStack(spacing: 4) {
            if hasDepth {
                ForEach(0..<max(bids.count, asks.count), id: \.self) { index in
                    let bid = index < bids.count ? bids[index] : nil
                    let ask = index < asks.count ? asks[index] : nil
                    HStack(spacing: 8) {
                        bidView(bid, maxQty: maxQty)
                        Text(centerPriceText(bid: bid?.price, ask: ask?.price))
                            .font(.dmMonoMedium(size: 12))
                            .foregroundColor(AppColors.primaryText)
                            .frame(width: 70)
                        askView(ask, maxQty: maxQty)
                    }
                }
            } else {
                VStack(spacing: 8) {
                    if let orderbookErrorMessage {
                        Text(orderbookErrorMessage)
                            .font(.dmMonoRegular(size: 13))
                            .foregroundColor(AppColors.secondaryText(opacity: 0.85))
                            .multilineTextAlignment(.center)
                        Button {
                            Task {
                                await loadAllOrderbooks(isInitial: true)
                            }
                        } label: {
                            Text("Retry")
                                .font(.dmMonoMedium(size: 13))
                        }
                    } else {
                        Text("No orders in the orderbook yet")
                            .font(.dmMonoRegular(size: 13))
                            .foregroundColor(AppColors.secondaryText(opacity: 0.75))
                        Text("You can still use Split and Merge below to rebalance existing positions.")
                            .font(.dmMonoRegular(size: 11))
                            .foregroundColor(AppColors.secondaryText(opacity: 0.5))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 32)
            }
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .frame(minHeight: 260, alignment: .top)
        .padding(8)
        .background(AppColors.cardBackground(opacity: 0.04))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func bidView(_ bid: DemoOrderbookLevel?, maxQty: Double) -> some View {
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
                    .font(.dmMonoMedium(size: 12))
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func askView(_ ask: DemoOrderbookLevel?, maxQty: Double) -> some View {
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
                    .font(.dmMonoMedium(size: 12))
                    .foregroundColor(.red)
                    .padding(.horizontal, 8)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {
            let canSplitMerge = hasBothMarkets
            
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Order Type")
                        .font(.dmMonoRegular(size: 13))
                        .foregroundColor(AppColors.secondaryText(opacity: 0.75))
                    Picker("", selection: $orderType) {
                        Text("Limit").tag(OrderType.limit)
                        Text("Market").tag(OrderType.market)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: orderType) { _, newType in
                        if newType == .market {
                            priceText = ""
                        } else if priceText.isEmpty {
                            let initialPrice = isBuyOrder 
                                ? (selectedSide == .yes ? outcome.yes.bestAsk : outcome.no.bestAsk)
                                : (selectedSide == .yes ? outcome.yes.bestBid : outcome.no.bestBid)
                            priceText = String(Int((initialPrice * 100).rounded()))
                        }
                    }
                }
                
                if orderType == .limit {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Price (%)")
                            .font(.dmMonoRegular(size: 13))
                            .foregroundColor(AppColors.secondaryText(opacity: 0.75))
                        TextField("Price", text: $priceText)
                            .keyboardType(.numberPad)
                            .font(.dmMonoMedium(size: 16))
                            .foregroundColor(AppColors.primaryText)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .background(AppColors.cardBackground(opacity: 0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quantity")
                        .font(.dmMonoRegular(size: 13))
                        .foregroundColor(AppColors.secondaryText(opacity: 0.75))
                    TextField("Quantity", text: $quantityText)
                        .keyboardType(.numberPad)
                        .font(.dmMonoMedium(size: 16))
                        .foregroundColor(AppColors.primaryText)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(AppColors.cardBackground(opacity: 0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                
                if let orderErrorMessage {
                    Text(orderErrorMessage)
                        .font(.dmMonoRegular(size: 12))
                        .foregroundColor(.red)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.25), value: orderType)
            
            HStack(spacing: 10) {
                Button {
                    isBuyOrder = true
                    if orderType == .limit {
                        let initialPrice = selectedSide == .yes ? outcome.yes.bestAsk : outcome.no.bestAsk
                        priceText = String(Int((initialPrice * 100).rounded()))
                    }
                    Task {
                        await handlePlaceOrder(isBuy: true)
                    }
                } label: {
                    HStack {
                        if isSubmittingOrder && isBuyOrder {
                            InlineLoadingView(color: Color.white)
                                .frame(width: 16, height: 16)
                        }
                        Text(isSubmittingOrder && isBuyOrder ? "Placing..." : (selectedSide == .yes ? "Buy Yes" : "Buy No"))
                            .font(.dmMonoMedium(size: 15))
                    }
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.green.opacity(0.22))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.green.opacity(0.35), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(marketId(for: selectedSide) == nil || isSubmittingOrder)
                .opacity(marketId(for: selectedSide) == nil ? 0.4 : 1)

                Button {
                    isBuyOrder = false
                    if orderType == .limit {
                        let initialPrice = selectedSide == .yes ? outcome.yes.bestBid : outcome.no.bestBid
                        priceText = String(Int((initialPrice * 100).rounded()))
                    }
                    Task {
                        await handlePlaceOrder(isBuy: false)
                    }
                } label: {
                    HStack {
                        if isSubmittingOrder && !isBuyOrder {
                            InlineLoadingView(color: Color.white)
                                .frame(width: 16, height: 16)
                        }
                        Text(isSubmittingOrder && !isBuyOrder ? "Placing..." : (selectedSide == .yes ? "Sell Yes" : "Sell No"))
                            .font(.dmMonoMedium(size: 15))
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.red.opacity(0.22))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.red.opacity(0.35), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(marketId(for: selectedSide) == nil || isSubmittingOrder)
                .opacity(marketId(for: selectedSide) == nil ? 0.4 : 1)
            }
            
            HStack(spacing: 10) {
                Button {
                    withAnimation {
                        advancedErrorMessage = nil
                        advancedSuccessMessage = nil
                        splitAmountText = ""
                        currentView = .split
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.triangle.branch")
                            .font(.dmMonoMedium(size: 12))
                        Text("Split")
                            .font(.dmMonoMedium(size: 13))
                    }
                    .foregroundColor(AppColors.primaryText)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(AppColors.cardBackground(opacity: 0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(AppColors.border(opacity: 0.14), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Split position")
                .disabled(!canSplitMerge)
                .opacity(canSplitMerge ? 1 : 0.4)
                
                Button {
                    withAnimation {
                        advancedErrorMessage = nil
                        advancedSuccessMessage = nil
                        currentView = .merge
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "square.stack.3d.down.right")
                            .font(.dmMonoMedium(size: 12))
                        Text("Merge")
                            .font(.dmMonoMedium(size: 13))
                    }
                    .foregroundColor(AppColors.primaryText)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(AppColors.cardBackground(opacity: 0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(AppColors.border(opacity: 0.14), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Merge positions")
                .disabled(!canSplitMerge)
                .opacity(canSplitMerge ? 1 : 0.4)
            }
            .padding(.top, 2)
        }
    }
    
    private func handlePlaceOrder(isBuy: Bool) async {
        guard let marketId = marketId(for: selectedSide) else {
            await MainActor.run {
                orderErrorMessage = "Trading is unavailable for this market."
            }
            return
        }
        
        let quantityTrimmed = quantityText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let quantityValue = UInt64(quantityTrimmed), quantityValue > 0 else {
            await MainActor.run {
                orderErrorMessage = "Enter a valid positive quantity."
            }
            return
        }
        
        var priceValue: UInt64?
        if orderType == .limit {
            let priceTrimmed = priceText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let priceInt = Int(priceTrimmed), priceInt > 0, priceInt <= 100 else {
                await MainActor.run {
                    orderErrorMessage = "Enter a valid price between 1 and 100."
                }
                return
            }
            priceValue = UInt64(priceInt)
        }
        
        let side: OrderSide = isBuy ? .bid : .ask
        let request = PlaceOrderRequest(
            marketId: marketId,
            side: side,
            orderType: orderType,
            price: priceValue,
            quantity: quantityValue
        )
        
        await MainActor.run {
            isSubmittingOrder = true
            orderErrorMessage = nil
        }
        
        do {
            _ = try await OrderService.shared.placeOrder(request)
            await MainActor.run {
                isSubmittingOrder = false
                quantityText = "10"
                if orderType == .limit {
                    let initialPrice = isBuy 
                        ? (selectedSide == .yes ? outcome.yes.bestAsk : outcome.no.bestAsk)
                        : (selectedSide == .yes ? outcome.yes.bestBid : outcome.no.bestBid)
                    priceText = String(Int((initialPrice * 100).rounded()))
                } else {
                    priceText = ""
                }
            }
            await loadAllOrderbooks(isInitial: false)
        } catch {
            await MainActor.run {
                isSubmittingOrder = false
                orderErrorMessage = error.localizedDescription
            }
        }
    }

    private func levelButton(_ count: Int) -> some View {
        Button {
            levelCount = count
        } label: {
            Text("\(count)")
                .font(.dmMonoMedium(size: 12))
                .foregroundColor(AppColors.primaryText)
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(count == levelCount ? AppColors.cardBackground(opacity: 0.16) : AppColors.cardBackground(opacity: 0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(AppColors.border(opacity: count == levelCount ? 0.0 : 0.14), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }
    
    private var splitContent: some View {
        VStack(spacing: 16) {
            splitHeader
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Allocate an amount into both the Yes and No markets for this outcome without placing new orders on the orderbook.")
                    .font(.dmMonoRegular(size: 13))
                    .foregroundColor(AppColors.secondaryText(opacity: 0.7))
                    .fixedSize(horizontal: false, vertical: true)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Amount")
                        .font(.dmMonoRegular(size: 13))
                        .foregroundColor(AppColors.secondaryText(opacity: 0.75))
                    TextField("Quantity", text: $splitAmountText)
                        .keyboardType(.numberPad)
                        .font(.dmMonoMedium(size: 16))
                        .foregroundColor(AppColors.primaryText)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 12)
                        .background(AppColors.cardBackground(opacity: 0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(AppColors.border(opacity: 0.14), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                
                if let advancedErrorMessage {
                    Text(advancedErrorMessage)
                        .font(.dmMonoRegular(size: 12))
                        .foregroundColor(.red)
                } else if let advancedSuccessMessage {
                    Text(advancedSuccessMessage)
                        .font(.dmMonoRegular(size: 12))
                        .foregroundColor(.green)
                }
                
                Button {
                    Task { await handleSplitConfirm() }
                } label: {
                    HStack {
                        if isSubmittingAdvanced {
                            InlineLoadingView()
                                .frame(width: 16, height: 16)
                        }
                        Text(isSubmittingAdvanced ? "Splitting..." : "Confirm Split")
                            .font(.dmMonoMedium(size: 15))
                    }
                    .foregroundColor(AppColors.primaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppColors.cardBackground(opacity: 0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(AppColors.border(opacity: 0.2), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .disabled(isSubmittingAdvanced)
                .buttonStyle(.plain)
            }
            .padding(.top, 8)
            
            Spacer()
        }
        .alert(isPresented: $showAdvancedAlert) {
            Alert(
                title: Text("Order Update"),
                message: Text(advancedAlertMessage ?? ""),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private var mergeContent: some View {
        VStack(spacing: 16) {
            mergeHeader
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Combine your exposure between the Yes and No markets for this outcome into a cleaner net position using your existing holdings.")
                    .font(.dmMonoRegular(size: 13))
                    .foregroundColor(AppColors.secondaryText(opacity: 0.7))
                    .fixedSize(horizontal: false, vertical: true)
                
                if let advancedErrorMessage {
                    Text(advancedErrorMessage)
                        .font(.dmMonoRegular(size: 12))
                        .foregroundColor(.red)
                } else if let advancedSuccessMessage {
                    Text(advancedSuccessMessage)
                        .font(.dmMonoRegular(size: 12))
                        .foregroundColor(.green)
                }
                
                Button {
                    Task { await handleMergeConfirm() }
                } label: {
                    HStack {
                        if isSubmittingAdvanced {
                            InlineLoadingView()
                                .frame(width: 16, height: 16)
                        }
                        Text(isSubmittingAdvanced ? "Merging..." : "Confirm Merge")
                            .font(.dmMonoMedium(size: 15))
                    }
                    .foregroundColor(AppColors.primaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppColors.cardBackground(opacity: 0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(AppColors.border(opacity: 0.2), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .disabled(isSubmittingAdvanced)
                .buttonStyle(.plain)
            }
            .padding(.top, 8)
            
            Spacer()
        }
    }
    
    private func handleSplitConfirm() async {
        guard let yesId = outcome.yes.marketId, let noId = outcome.no.marketId else {
            await MainActor.run {
                advancedErrorMessage = "Markets unavailable for this outcome."
                advancedAlertMessage = advancedErrorMessage
                showAdvancedAlert = true
            }
            return
        }
        
        let trimmed = splitAmountText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let amount = UInt64(trimmed), amount > 0 else {
            await MainActor.run {
                advancedErrorMessage = "Enter a valid positive amount."
                advancedAlertMessage = advancedErrorMessage
                showAdvancedAlert = true
            }
            return
        }
        
        let request = SplitOrderRequest(market1Id: yesId, market2Id: noId, amount: amount)
        
        await MainActor.run {
            isSubmittingAdvanced = true
            advancedErrorMessage = nil
            advancedSuccessMessage = nil
            advancedAlertMessage = nil
        }
        
        do {
            _ = try await OrderService.shared.splitOrder(request)
            await MainActor.run {
                isSubmittingAdvanced = false
                advancedSuccessMessage = "Split submitted successfully."
                advancedAlertMessage = advancedSuccessMessage
                showAdvancedAlert = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        currentView = .orderbook
                        splitAmountText = ""
                    }
                }
            }
        } catch {
            await MainActor.run {
                isSubmittingAdvanced = false
                advancedErrorMessage = error.localizedDescription
                advancedAlertMessage = advancedErrorMessage
                showAdvancedAlert = true
            }
        }
    }
    
    private func handleMergeConfirm() async {
        guard let yesId = outcome.yes.marketId, let noId = outcome.no.marketId else {
            await MainActor.run {
                advancedErrorMessage = "Markets unavailable for this outcome."
                advancedAlertMessage = advancedErrorMessage
                showAdvancedAlert = true
            }
            return
        }
        
        let request = MergeOrderRequest(market1Id: yesId, market2Id: noId)
        
        await MainActor.run {
            isSubmittingAdvanced = true
            advancedErrorMessage = nil
            advancedSuccessMessage = nil
            advancedAlertMessage = nil
        }
        
        do {
            _ = try await OrderService.shared.mergeOrder(request)
            await MainActor.run {
                isSubmittingAdvanced = false
                advancedSuccessMessage = "Merge submitted successfully."
                advancedAlertMessage = advancedSuccessMessage
                showAdvancedAlert = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        currentView = .orderbook
                    }
                }
            }
        } catch {
            await MainActor.run {
                isSubmittingAdvanced = false
                advancedErrorMessage = error.localizedDescription
                advancedAlertMessage = advancedErrorMessage
                showAdvancedAlert = true
            }
        }
    }

    private func expand(book: DemoOrderbook, to levels: Int) -> DemoOrderbook {
        if book.bids.count >= levels && book.asks.count >= levels {
            return book
        }
        let tick = 0.01
        var bids = book.bids
        var asks = book.asks

        if let lastBid = bids.last {
            while bids.count < levels {
                let next = DemoOrderbookLevel(
                    price: max(0.0, lastBid.price - tick * Double(bids.count - book.bids.count + 1)),
                    size: lastBid.size * (1.0 + 0.2 * Double(bids.count - book.bids.count + 1))
                )
                bids.append(next)
            }
        }

        if let lastAsk = asks.last {
            while asks.count < levels {
                let next = DemoOrderbookLevel(
                    price: min(1.0, lastAsk.price + tick * Double(asks.count - book.asks.count + 1)),
                    size: lastAsk.size * (1.0 + 0.2 * Double(asks.count - book.asks.count + 1))
                )
                asks.append(next)
            }
        }
        return DemoOrderbook(
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


