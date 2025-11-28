import SwiftUI

struct EventHeroImageView: View {
    let imageName: String
    let availableWidth: CGFloat

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(height: min(availableWidth * 0.42, 180))
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

