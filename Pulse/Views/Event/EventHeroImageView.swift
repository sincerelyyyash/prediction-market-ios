import SwiftUI
import UIKit

struct EventHeroImageView: View {
    let imageName: String
    let imgUrl: String?
    let availableWidth: CGFloat

    var body: some View {
        Group {
            if let imgUrl, let url = URL(string: imgUrl) {
                // Load image from network URL
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white.opacity(0.6))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.white.opacity(0.04))
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        fallbackImage
                    @unknown default:
                        fallbackImage
                    }
                }
            } else {
                fallbackImage
            }
        }
        .frame(height: min(availableWidth * 0.42, 180))
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    @ViewBuilder
    private var fallbackImage: some View {
        let uiImage = UIImage(named: imageName) ?? UIImage(named: "eventPlaceholder")
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
}

