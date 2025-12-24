import SwiftUI

struct HomeSearchField: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppColors.secondaryText(opacity: 0.7))
            TextField(
                "Search events, markets, categories",
                text: $text
            )
            .textInputAutocapitalization(.none)
            .autocorrectionDisabled()
            .foregroundColor(AppColors.primaryText)
            .font(.dmMonoRegular(size: 15))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background(AppColors.cardBackground(opacity: 0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

