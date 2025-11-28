import SwiftUI

struct OnboardingView: View {
    @State private var glow = false
    @State private var showSignIn = false
    @State private var showSignUp = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                BackgroundGradientView(maxDimension: max(geo.size.width, geo.size.height))
                VStack(spacing: 24) {
                    Spacer(minLength: 16)
                    OnboardingHeroView(
                        glow: glow,
                        maxWidth: geo.size.width
                    )
                    OnboardingCopyView()
                    OnboardingCTAView(
                        handlePrimary: handleSignIn,
                        handleSecondary: handleSignUp
                    )
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .onAppear {
                glow = true
            }
            .sheet(isPresented: $showSignIn) {
                SignInView()
                    .preferredColorScheme(.dark)
            }
            .sheet(isPresented: $showSignUp) {
                SignUpView()
                    .preferredColorScheme(.dark)
            }
        }
    }

    private func handleSignIn() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        showSignIn = true
    }

    private func handleSignUp() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        showSignUp = true
    }
}

#Preview {
    OnboardingView()
        .preferredColorScheme(.dark)
}
