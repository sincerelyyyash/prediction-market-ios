import SwiftUI

struct CategoryChipView: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.dmMonoMedium(size: 13))
                Text(title)
                    .font(.dmMonoRegular(size: 13))
            }
            .foregroundColor(isSelected ? .black : .white)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(isSelected ? Color.white : Color.white.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(isSelected ? 0.0 : 0.18), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

