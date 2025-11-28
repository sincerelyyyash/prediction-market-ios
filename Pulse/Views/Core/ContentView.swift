import SwiftUI
import UIKit

struct ContentView: View {
    init() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .black

        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label(Constants.homeString, systemImage: Constants.homeIconString)
                }
            MarketView()
                .tabItem {
                    Label(Constants.marketString, systemImage: Constants.marketIconString)
                }
            PortfolioView()
                .tabItem {
                    Label(Constants.portfolioString, systemImage: Constants.portfolioIconString)
                }
            ProfileView()
                .tabItem {
                    Label(Constants.profileString, systemImage: Constants.profileIconString)
                }
        }
        .tint(.white)
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
