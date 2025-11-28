import SwiftUI

struct OnboardingView: View {
    @State private var glow = false
    @State private var showSignIn = false
    @State private var showSignUp = false
    @State private var showApp = false

    var body: some View {
        Group {
            if showApp {
                ContentView()
                    .preferredColorScheme(.dark)
            } else {
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
                                handlePrimary: handleStartTrading,
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
        }
    }

    private func handleStartTrading() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        showApp = true
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
