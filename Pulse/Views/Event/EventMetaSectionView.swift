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
                .font(.dmMonoMedium(size: 22))
                .foregroundColor(AppColors.primaryText)
                .lineLimit(3)
            if let subtitle = event.subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.dmMonoRegular(size: 14))
                    .foregroundColor(AppColors.secondaryText(opacity: 0.9))
                    .lineLimit(2)
            }
        }
    }
}

