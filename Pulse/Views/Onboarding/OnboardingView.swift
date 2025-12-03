import SwiftUI

struct OnboardingView: View {
    private enum AuthRoute: Hashable {
        case signIn
        case signUp
    }

    @State private var glow = false
    @State private var path: [AuthRoute] = []
    @State private var showApp = false

    var body: some View {
        Group {
            if showApp {
                ContentView()
                    .preferredColorScheme(.dark)
            } else {
                NavigationStack(path: $path) {
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
                                    handleStartTrading: handleStartTrading,
                                    handleSignUp: handleSignUp
                                )
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        }
                        .onAppear {
                            glow = true
                        }
                    }
                    .navigationDestination(for: AuthRoute.self) { route in
                        switch route {
                        case .signIn:
                            SignInView(
                                onAuthSuccess: handleAuthSuccess,
                                navigateToSignUp: { handleNavigateToSignUp() }
                            )
                            .preferredColorScheme(.dark)
                        case .signUp:
                            SignUpView(
                                onAuthSuccess: handleAuthSuccess,
                                navigateToSignIn: { handleNavigateToSignIn() }
                            )
                            .preferredColorScheme(.dark)
                        }
                    }
                }
            }
        }
    }

    private func handleStartTrading() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        // Instead of navigating to Sign In, go straight to the app
//        showApp = true
        path.append(.signIn)
    }

    private func handleSignIn() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        path.append(.signIn)
    }

    private func handleSignUp() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        path.append(.signUp)
    }

    private func handleNavigateToSignUp() {
        path = [.signUp]
    }

    private func handleNavigateToSignIn() {
        path = [.signIn]
    }

    private func handleAuthSuccess() {
        path.removeAll()
        showApp = true
    }
}

#Preview {
    OnboardingView()
        .preferredColorScheme(.dark)
}
