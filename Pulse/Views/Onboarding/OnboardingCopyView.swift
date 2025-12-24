import SwiftUI

struct OnboardingCopyView: View {
    var body: some View {
        VStack(spacing: 10) {
            Text(Constants.onboardingString)
                .font(.custom("DMMono-Light", size: 28))
                .foregroundColor(AppColors.primaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(0)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .padding(.horizontal, 40)
                .accessibilityLabel(Constants.onboardingString)
            Text("Capture the Pulse of Market.")
                .font(.custom("DMMono-Light", size: 16))
                .foregroundColor(AppColors.secondaryText(opacity: 0.78))
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .padding(.horizontal, 36)
        }
    }
}

