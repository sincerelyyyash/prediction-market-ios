import SwiftUI

struct OnboardingCTAView: View {
    let handlePrimary: () -> Void
    let handleSecondary: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Button(action: handlePrimary) {
                Text(Constants.onboardinButtonString)
                    .font(.custom("DMMono-Medium", size: 20))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .contentShape(Rectangle())
            }
            .padding(.horizontal, 40)
            .accessibilityLabel(Constants.onboardinButtonString)
            .accessibilityAddTraits(.isButton)
            Button(action: handleSecondary) {
                HStack(spacing: 6) {
                    Text("Don’t have an account?")
                        .foregroundColor(.white.opacity(0.8))
                    Text("Sign Up")
                        .foregroundColor(.white)
                }
                .font(.custom("DMMono-Light", size: 16))
                .padding(.vertical, 8)
                .contentShape(Rectangle())
            }
            .accessibilityLabel("Don't have an account? Sign up")
        }
    }
}

