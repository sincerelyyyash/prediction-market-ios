import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label(Constants.homeString, systemImage: Constants.homeIconString)
                }
            PlaceholderTab(title: Constants.marketString)
                .tabItem {
                    Label(Constants.marketString, systemImage: Constants.marketIconString)
                }
            PlaceholderTab(title: Constants.portfolioString)
                .tabItem {
                    Label(Constants.portfolioString, systemImage: Constants.portfolioIconString)
                }
            PlaceholderTab(title: Constants.profileString)
                .tabItem {
                    Label(Constants.profileString, systemImage: Constants.profileIconString)
                }
        }
    }
}

private struct PlaceholderTab: View {
    let title: String

    var body: some View {
        VStack {
            Spacer()
            Text("\(title) coming soon")
                .foregroundColor(.white.opacity(0.6))
            Spacer()
        }
        .background(Color.black.ignoresSafeArea())
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
