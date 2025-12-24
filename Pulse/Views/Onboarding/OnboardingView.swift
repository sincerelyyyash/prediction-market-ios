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
        ZStack {
            if showApp {
                ContentView()
                    .transition(.fadeTransition)
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
                        Group {
                            switch route {
                            case .signIn:
                                SignInView(
                                    onAuthSuccess: handleAuthSuccess,
                                    navigateToSignUp: { handleNavigateToSignUp() }
                                )
                                .transition(.slideFromTrailing)
                            case .signUp:
                                SignUpView(
                                    onAuthSuccess: handleAuthSuccess,
                                    navigateToSignIn: { handleNavigateToSignIn() }
                                )
                                .transition(.slideFromTrailing)
                            }
                        }
                    }
                }
                .transition(.fadeTransition)
            }
        }
        .animation(.slideTransition, value: showApp)
    }

    private func handleStartTrading() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation(.slideTransition) {
            path.append(.signIn)
        }
    }

    private func handleSignIn() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.slideTransition) {
            path.append(.signIn)
        }
    }

    private func handleSignUp() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.slideTransition) {
            path.append(.signUp)
        }
    }

    private func handleNavigateToSignUp() {
        withAnimation(.slideTransition) {
            path = [.signUp]
        }
    }

    private func handleNavigateToSignIn() {
        withAnimation(.slideTransition) {
            path = [.signIn]
        }
    }

    private func handleAuthSuccess() {
        withAnimation(.fadeTransition) {
            path.removeAll()
            showApp = true
        }
    }
}

#Preview {
    OnboardingView()
}
