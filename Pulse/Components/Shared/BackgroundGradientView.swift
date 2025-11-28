import SwiftUI

struct BackgroundGradientView: View {
    var maxDimension: CGFloat = 600
    var endRadiusMultiplier: CGFloat = 0.9

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()
            RadialGradient(
                gradient: Gradient(stops: [
                    .init(color: .white, location: 0.0),
                    .init(color: Color(red: 0.7, green: 0.7, blue: 0.75), location: 0.0),
                    .init(color: .black, location: 0.4)
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

