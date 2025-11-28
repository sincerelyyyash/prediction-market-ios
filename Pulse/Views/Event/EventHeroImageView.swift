import SwiftUI
import UIKit

struct EventHeroImageView: View {
    let imageName: String
    let availableWidth: CGFloat

    var body: some View {
        let uiImage = UIImage(named: imageName) ?? UIImage(named: "eventPlaceholder")
        Group {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                // Fallback visual if even placeholder is missing
                ZStack {
                    LinearGradient(
                        colors: [Color.white.opacity(0.08), Color.white.opacity(0.02)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Image(systemName: "photo")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .frame(height: min(availableWidth * 0.42, 180))
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

