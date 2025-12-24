import SwiftUI
import UIKit

struct OutcomeIconView: View {
    let imgUrl: String?
    let size: CGFloat
    
    init(imgUrl: String?, size: CGFloat = 40) {
        self.imgUrl = imgUrl
        self.size = size
    }
    
    var body: some View {
        Group {
            if let imgUrl, let url = URL(string: imgUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholderView
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        placeholderView
                    @unknown default:
                        placeholderView
                    }
                }
            } else {
                placeholderView
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
    
    @ViewBuilder
    private var placeholderView: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [AppColors.cardBackground(opacity: 0.12), AppColors.cardBackground(opacity: 0.06)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Image(systemName: "person.circle.fill")
                .font(.system(size: size * 0.6, weight: .medium))
                .foregroundColor(AppColors.secondaryText(opacity: 0.6))
        }
    }
}

