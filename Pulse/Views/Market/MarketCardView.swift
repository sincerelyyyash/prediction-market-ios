import SwiftUI
import Foundation

struct MarketCardView: View {
    let content: MarketCardContent
    let handleOpen: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            titleSection
            leadingOutcomeHint
            actionRow
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
        .contentShape(Rectangle())
        .onTapGesture {
            handleOpen()
        }
    }

    private var header: some View {
        HStack {
            Label(content.categoryTitle, systemImage: content.categoryIconName)
                .font(.dmMonoMedium(size: 12))
                .foregroundColor(.white.opacity(0.8))
            Spacer()
            Text(content.timeRemainingText)
                .font(.dmMonoMedium(size: 12))
                .foregroundColor(.white.opacity(0.8))
        }
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(content.title)
                .font(.dmMonoMedium(size: 17))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
            if let subtitle = content.subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.dmMonoRegular(size: 13))
                    .foregroundColor(.white.opacity(0.75))
                    .lineLimit(2)
            }
        }
    }

    private var leadingOutcomeHint: some View {
        HStack(spacing: 8) {
            Text("Trading \(content.leadingOutcomeName) — top market right now")
                .font(.dmMonoRegular(size: 12))
                .foregroundColor(.white.opacity(0.72))
                .lineLimit(1)
            Spacer()
        }
    }

    private var actionRow: some View {
        HStack(spacing: 10) {
            tradeButton(
                title: "Yes \(percentageText(content.leadingYesProbability))",
                foreground: .green,
                background: Color.green.opacity(0.22),
                border: Color.green.opacity(0.35)
            )
            tradeButton(
                title: "No \(percentageText(content.leadingNoProbability))",
                foreground: .red,
                background: Color.red.opacity(0.22),
                border: Color.red.opacity(0.35)
            )
        }
    }

    private func tradeButton(
        title: String,
        foreground: Color,
        background: Color,
        border: Color
    ) -> some View {
        Button {
            handleOpen()
        } label: {
            Text(title)
                .font(.dmMonoMedium(size: 15))
                .foregroundColor(foreground)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(background)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(border, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func percentageText(_ value: Double) -> String {
        "\(Int((value * 100).rounded()))%"
    }
}

struct MarketCardContent {
    let title: String
    let subtitle: String?
    let categoryTitle: String
    let categoryIconName: String
    let timeRemainingText: String
    let leadingOutcomeName: String
    let leadingDescription: String
    let leadingYesProbability: Double
    let leadingNoProbability: Double
}
