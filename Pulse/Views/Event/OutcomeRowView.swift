import SwiftUI

struct OutcomeRowView: View {
    let outcome: OutcomeMarket
    let handleBuyYes: () -> Void
    let handleBuyNo: () -> Void
    let handleOpenOrderbook: () -> Void

    private var isYesTradable: Bool {
        outcome.yes.marketId != nil
    }

    private var isNoTradable: Bool {
        outcome.no.marketId != nil
    }

    var body: some View {
        HStack(spacing: 10) {
            Text(outcome.name)
                .font(.dmMonoMedium(size: 15))
                .foregroundColor(.white)
                .lineLimit(1)
            Spacer(minLength: 8)
            CompactActionButton(
                title: "Yes \(percentageText(outcome.yes.price))",
                style: .yes,
                action: handleBuyYes
            )
            .disabled(!isYesTradable)
            .opacity(isYesTradable ? 1 : 0.4)
            CompactActionButton(
                title: "No \(percentageText(outcome.no.price))",
                style: .no,
                action: handleBuyNo
            )
            .disabled(!isNoTradable)
            .opacity(isNoTradable ? 1 : 0.4)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
        .contentShape(Rectangle())
        .onTapGesture {
            handleOpenOrderbook()
        }
    }

    private func percentageText(_ value: Double) -> String {
        "\(Int((value * 100).rounded()))%"
    }
}

