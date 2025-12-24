import SwiftUI

struct AuthScreenContainer<Fields: View, Footer: View>: View {
    let title: String
    let actionTitle: String
    let handleAction: () -> Void
    @ViewBuilder let fields: Fields
    @ViewBuilder let footer: Footer

    var body: some View {
        GeometryReader { geo in
            ZStack {
                BackgroundGradientView(
                    maxDimension: geo.size.height,
                    endRadiusMultiplier: 0.6
                )
                VStack {
                    Spacer()
                    VStack(spacing: 16) {
                        Text(title)
                            .font(.custom("DMMono-Medium", size: 28))
                            .foregroundColor(AppColors.primaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        fields
                        Button(action: handleAction) {
                            Text(actionTitle)
                                .font(.custom("DMMono-Medium", size: 20))
                                .foregroundColor(AppColors.background)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(AppColors.primaryText)
                                .cornerRadius(14)
                        }
                        .padding(.top, 10)
                        footer
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 24)
                }
            }
        }
    }
}

