import SwiftUI

struct OnboardingCTAView: View {
    let handleStartTrading: () -> Void   // Should navigate to Sign In
    let handleSignUp: () -> Void         // Secondary text link
    
    var body: some View {
        VStack(spacing: 14) {
            Button(action: handleStartTrading) {
                Text(Constants.onboardinButtonString)
                    .font(.dmMonoMedium(size: 20))
                    .foregroundColor(AppColors.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(AppColors.primaryText)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .contentShape(Rectangle())
            }
            .padding(.horizontal, 40)
            .accessibilityLabel(Constants.onboardinButtonString)
            .accessibilityAddTraits(.isButton)
            
            Button(action: handleSignUp) {
                HStack(spacing: 6) {
                    Text("Don't have an account?")
                        .foregroundColor(AppColors.secondaryText(opacity: 0.8))
                    Text("Sign Up")
                        .foregroundColor(AppColors.primaryText)
                }
                .font(.dmMonoRegular(size: 16))
                .padding(.vertical, 8)
                .contentShape(Rectangle())
            }
            .accessibilityLabel("Don't have an account? Sign up")
        }
    }
}

