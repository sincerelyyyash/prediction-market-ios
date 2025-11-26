import SwiftUI

struct Onboarding: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                
                Color.black
                    .ignoresSafeArea()

                RadialGradient(
                    gradient: Gradient(stops: [
                        .init(color: .white, location: 0.0),
                        .init(color: Color(red: 0.7, green: 0.7, blue: 0.75), location: 0.35),
                        .init(color: .black, location: 0.7)
                    ]),
                    center: .top,
                    startRadius: 0,
                    endRadius: 600       
                )
                .frame(height: geo.size.height * 0.5)
                .frame(maxHeight: .infinity, alignment: .top)
                .ignoresSafeArea(edges: .top)
                .allowsHitTesting(false)


                
                VStack(spacing: 20) {

                    Image("onboarding1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300)
                        .padding(.horizontal)

                    Text(Constants.onboardingString)
                        .font(.custom("DMMono-Regular", size: 22))
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    
                    Button(action: {
                        // action
                    }) {
                        Text(Constants.onboardinButtonString)
                            .font(.custom("DMMono-Medium", size: 20))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 40)

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

#Preview {
    Onboarding()
}
