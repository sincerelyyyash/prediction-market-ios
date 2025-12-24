import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var authService = AuthService.shared

    init() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? .black : .white
        }

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
        .task {
            await performInitialDataCheck()
        }
        .tint(AppColors.primaryText)
    }

    private func performInitialDataCheck() async {
        // If there's no token at all, sign out so RootView sends user to onboarding.
        if !TokenManager.shared.isAuthenticated() {
            await MainActor.run {
                authService.signOut()
            }
            return
        }

        do {
            async let balanceTask = UserService.shared.getBalance()
            async let portfolioTask = PositionService.shared.getPortfolio()
            _ = try await (balanceTask, portfolioTask)
        } catch {
            let message = error.localizedDescription.lowercased()
            if message.contains("jwt secret") || message.contains("jwt") {
                await MainActor.run {
                    authService.signOut()
                }
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
                .foregroundColor(AppColors.secondaryText(opacity: 0.6))
            Spacer()
        }
        .background(AppColors.background.ignoresSafeArea())
    }
}

#Preview {
    ContentView()
}
