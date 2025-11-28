import SwiftUI

struct HomeView: View {
    @State private var searchText = ""
    @State private var selectedCategory: EventCategory?

    var body: some View {
        GeometryReader { geo in
            ZStack {
                backgroundGradient(for: geo)
                VStack(spacing: 0) {
                    Spacer(minLength: 8)
                    HomeHeaderView(
                        searchText: $searchText,
                        selectedCategory: $selectedCategory
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 6)
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(filteredEvents) { event in
                                EventCardView(
                                    event: event,
                                    yesAction: { /* hook yes */ },
                                    noAction: { /* hook no */ }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                }
            }
        }
    }

    private func backgroundGradient(for geo: GeometryProxy) -> some View {
        ZStack {
            Color.black.ignoresSafeArea()
            RadialGradient(
                gradient: Gradient(stops: [
                    .init(color: .white, location: 0.0),
                    .init(color: Color(red: 0.7, green: 0.7, blue: 0.75), location: 0.0),
                    .init(color: .black, location: 0.4)
                ]),
                center: .top,
                startRadius: 0,
                endRadius: max(geo.size.width, geo.size.height) * 0.9
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
    }

    private var filteredEvents: [Event] {
        Constants.placeholderEvents.filter { event in
            let matchesCategory = selectedCategory == nil || event.category == selectedCategory
            guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
                return matchesCategory
            }
            return matchesCategory &&
                event.title.localizedCaseInsensitiveContains(searchText)
        }
    }
}

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
}
