import SwiftUI

struct OrderTicketConfig: Identifiable, Equatable {
    let id = UUID()
    let outcome: OutcomeMarket
    let side: MarketSideType
    let isBuy: Bool
    let initialPrice: Double?
}

struct OrderTicketView: View {
    let config: OrderTicketConfig
    let handleDismiss: () -> Void

    @State private var orderType: OrderType = .limit
    @State private var priceText: String
    @State private var quantityText: String = "10"
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    init(config: OrderTicketConfig, handleDismiss: @escaping () -> Void) {
        self.config = config
        self.handleDismiss = handleDismiss
        _priceText = State(initialValue: OrderTicketView.defaultPriceText(for: config))
    }

    private static func defaultPriceText(for config: OrderTicketConfig) -> String {
        if let price = config.initialPrice {
            return String(Int((price * 100).rounded()))
        }
        return ""
    }

    private var titleText: String {
        let sideText = config.side == .yes ? "Yes" : "No"
        let actionText = config.isBuy ? "Buy" : "Sell"
        return "\(actionText) \(sideText)"
    }

    private var marketColor: Color {
        config.side.color
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(config.outcome.name)
                        .font(.dmMonoMedium(size: 18))
                        .foregroundColor(.white)
                    Text(titleText)
                        .font(.dmMonoRegular(size: 13))
                        .foregroundColor(marketColor)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Order Type")
                        .font(.dmMonoRegular(size: 13))
                        .foregroundColor(.white.opacity(0.75))
                    Picker("", selection: $orderType) {
                        Text("Limit").tag(OrderType.limit)
                        Text("Market").tag(OrderType.market)
                    }
                    .pickerStyle(.segmented)
                }

                if orderType == .limit {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Price (%)")
                            .font(.dmMonoRegular(size: 13))
                            .foregroundColor(.white.opacity(0.75))
                        TextField("Price", text: $priceText)
                            .keyboardType(.numberPad)
                            .font(.dmMonoMedium(size: 16))
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 10)
                            .background(Color.white.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Quantity")
                        .font(.dmMonoRegular(size: 13))
                        .foregroundColor(.white.opacity(0.75))
                    TextField("Quantity", text: $quantityText)
                        .keyboardType(.numberPad)
                        .font(.dmMonoMedium(size: 16))
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.dmMonoRegular(size: 12))
                        .foregroundColor(.red)
                }

                Button {
                    Task {
                        await handleSubmit()
                    }
                } label: {
                    HStack {
                        if isSubmitting {
                            InlineLoadingView(color: .black)
                        }
                        Text(isSubmitting ? "Placing Order..." : "Place Order")
                            .font(.dmMonoMedium(size: 15))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(marketColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .disabled(isSubmitting)
                .buttonStyle(.plain)

                Spacer()
            }
            .padding(16)
            .background(Color.black.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        handleDismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }

    private func handleSubmit() async {
        await MainActor.run {
            errorMessage = nil
        }

        guard let marketId = marketIdForConfig() else {
            await MainActor.run {
                errorMessage = "Trading is unavailable for this market."
            }
            return
        }

        let quantityTrimmed = quantityText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let quantityValue = UInt64(quantityTrimmed), quantityValue > 0 else {
            await MainActor.run {
                errorMessage = "Enter a valid positive quantity."
            }
            return
        }

        var priceValue: UInt64?
        if orderType == .limit {
            let priceTrimmed = priceText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let priceInt = Int(priceTrimmed), priceInt > 0, priceInt <= 100 else {
                await MainActor.run {
                    errorMessage = "Enter a valid price between 1 and 100."
                }
                return
            }
            priceValue = UInt64(priceInt)
        }

        let side: OrderSide = config.isBuy ? .bid : .ask
        let request = PlaceOrderRequest(
            marketId: marketId,
            side: side,
            orderType: orderType,
            price: priceValue,
            quantity: quantityValue
        )

        await MainActor.run {
            isSubmitting = true
        }

        do {
            _ = try await OrderService.shared.placeOrder(request)
            await MainActor.run {
                isSubmitting = false
                handleDismiss()
            }
        } catch {
            await MainActor.run {
                isSubmitting = false
                errorMessage = error.localizedDescription
            }
        }
    }

    private func marketIdForConfig() -> UInt64? {
        if config.side == .yes {
            return config.outcome.yes.marketId
        }
        return config.outcome.no.marketId
    }
}


