import SwiftUI

struct PageIntroHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.dmMonoMedium(size: 26))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(subtitle)
                .font(.dmMonoRegular(size: 13))
                .foregroundColor(.white.opacity(0.75))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}


