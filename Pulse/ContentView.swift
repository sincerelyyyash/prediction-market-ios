import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            
            Text(Constants.homeString)
                .tabItem {
                    Label(Constants.homeString, systemImage: Constants.homeIconString)
                }

            Text(Constants.marketString)
                .tabItem {
                    Label(Constants.marketString, systemImage: Constants.marketIconString)
                }

            Text(Constants.portfolioString)
                .tabItem {
                    Label(Constants.portfolioString, systemImage: Constants.portfolioIconString)
                }
            
//            Text(Constants.searchString)
//                .tabItem {
//                    Label(Constants.searchString, systemImage: Constants.searchIconString)
//                }
            
            Text(Constants.profileString)
                .tabItem {
                    Label(Constants.profileString, systemImage: Constants.profileIconString)
                }
        }
    }
}

#Preview {
    ContentView()
}
