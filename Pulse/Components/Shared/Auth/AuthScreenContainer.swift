import SwiftUI

struct AuthScreenContainer<Fields: View>: View {
    let title: String
    let actionTitle: String
    let handleAction: () -> Void
    @ViewBuilder let fields: Fields

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
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        fields
                        Button(action: handleAction) {
                            Text(actionTitle)
                                .font(.custom("DMMono-Medium", size: 20))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.white)
                                .cornerRadius(14)
                        }
                        .padding(.top, 10)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 24)
                }
            }
        }
    }
}

