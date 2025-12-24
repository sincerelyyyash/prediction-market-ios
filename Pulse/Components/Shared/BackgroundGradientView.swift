import SwiftUI

struct BackgroundGradientView: View {
    var maxDimension: CGFloat = 600
    var endRadiusMultiplier: CGFloat = 0.9

    var body: some View {
        ZStack(alignment: .top) {
            AppColors.background.ignoresSafeArea()
            RadialGradient(
                gradient: Gradient(stops: [
                    .init(color: AppColors.gradientStart, location: 0.0),
                    .init(color: AppColors.gradientMiddle, location: 0.15),
                    .init(color: AppColors.gradientEnd, location: 0.4)
                ]),
                center: .top,
                startRadius: 0,
                endRadius: maxDimension * endRadiusMultiplier
            )
            .frame(height: maxDimension * 0.55)
            .frame(maxWidth: .infinity, alignment: .top)
            .ignoresSafeArea(edges: .top)
            .allowsHitTesting(false)
        }
    }
}

