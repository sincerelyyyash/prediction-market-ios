import SwiftUI

struct EventDescriptionView: View {
    let descriptionText: String?

    @ViewBuilder
    var body: some View {
        if let descriptionText, !descriptionText.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Overview")
                    .font(.dmMonoRegular(size: 14))
                    .foregroundColor(.white.opacity(0.85))
                Text(descriptionText)
                    .font(.dmMonoRegular(size: 15))
                    .foregroundColor(.white.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

