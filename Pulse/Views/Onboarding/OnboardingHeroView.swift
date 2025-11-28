import SwiftUI

struct OnboardingHeroView: View {
    let glow: Bool
    let maxWidth: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            .white.opacity(glow ? 0.16 : 0.06),
                            .white.opacity(0.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .blur(radius: glow ? 46 : 28)
                .scaleEffect(glow ? 1.05 : 0.95)
                .frame(
                    width: min(maxWidth * 0.95, 380),
                    height: min(maxWidth * 0.95, 380)
                )
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: glow)
            Image("onboarding1")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: min(maxWidth * 0.75, 360))
                .accessibilityHidden(true)
        }
        .padding(.horizontal)
    }
}

