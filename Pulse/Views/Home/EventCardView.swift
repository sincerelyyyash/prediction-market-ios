import SwiftUI

struct EventCardView: View {
    let event: Event
    let yesAction: () -> Void
    let noAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let imgUrl = event.imgUrl, let url = URL(string: imgUrl) {
                thumbnailImage(url: url)
            }
            header
            titleSection
            statusSection
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
    }

    @ViewBuilder
    private func thumbnailImage(url: URL) -> some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                Color.white.opacity(0.04)
                    .frame(height: 100)
                    .overlay(
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white.opacity(0.5))
                    )
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(height: 100)
                    .clipped()
            case .failure:
                EmptyView()
            @unknown default:
                EmptyView()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var header: some View {
        HStack {
            Label(event.category.rawValue, systemImage: event.category.systemIcon)
                .font(.dmMonoMedium(size: 12))
                .foregroundColor(.white.opacity(0.8))
            Spacer()
            Text(event.timeRemainingText)
                .font(.dmMonoMedium(size: 12))
                .foregroundColor(event.isResolved ? .white.opacity(0.7) : .white.opacity(0.8))
        }
    }

    private var titleSection: some View {
        Text(event.title)
            .font(.dmMonoMedium(size: 17))
            .foregroundColor(.white)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var statusSection: some View {
        Group {
            if event.isResolved {
                resolvedView
            } else {
                probabilitiesView
            }
        }
    }

    private var actionRow: some View {
        HStack(spacing: 10) {
            ActionButton(
                title: "Yes \(percentageText(event.yesProbability))",
                style: .yes,
                action: yesAction
            )
            ActionButton(
                title: "No \(percentageText(event.noProbability))",
                style: .no,
                action: noAction
            )
        }
    }

    private var resolvedView: some View {
        HStack(spacing: 8) {
            Text("Outcome:")
                .font(.dmMonoRegular(size: 13))
                .foregroundColor(.white.opacity(0.8))
            Text(event.outcome == .yes ? "Yes" : "No")
                .font(.dmMonoMedium(size: 13))
                .foregroundColor(event.outcome == .yes ? .green : .red)
            Spacer()
        }
    }

    private var probabilitiesView: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Market Odds")
                    .font(.dmMonoRegular(size: 12))
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
            }
            HStack(spacing: 10) {
                ProbabilityPillView(label: "Yes", value: event.yesProbability, color: .green)
                ProbabilityPillView(label: "No", value: event.noProbability, color: .red)
                Spacer()
            }
        }
    }

    private func percentageText(_ value: Double) -> String {
        "\(Int((value * 100).rounded()))%"
    }
}

