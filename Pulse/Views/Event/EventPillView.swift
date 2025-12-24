import SwiftUI

struct EventPillView: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.dmMonoMedium(size: 12))
            Text(text)
                .font(.dmMonoMedium(size: 12))
        }
        .foregroundColor(AppColors.primaryText)
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(AppColors.cardBackground(opacity: 0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(AppColors.border(opacity: 0.18), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

