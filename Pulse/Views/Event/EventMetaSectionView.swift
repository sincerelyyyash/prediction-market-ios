import SwiftUI

struct EventMetaSectionView: View {
    let event: EventDetail

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                EventPillView(icon: event.category.systemIcon, text: event.category.rawValue)
                EventPillView(icon: "clock", text: event.timeRemainingText)
            }
            Text(event.title)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(3)
            if let subtitle = event.subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(2)
            }
        }
    }
}

