import SwiftUI

struct HomeHeaderView: View {
    @Binding var searchText: String
    @Binding var selectedCategory: EventCategory?

    var body: some View {
        VStack(spacing: 12) {
            HomeSearchField(text: $searchText)
            CategoryScrollView(
                selectedCategory: $selectedCategory
            )
        }
    }
}

private struct CategoryScrollView: View {
    @Binding var selectedCategory: EventCategory?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                CategoryChipView(
                    title: "All",
                    icon: "line.3.horizontal.decrease.circle",
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }
                ForEach(EventCategory.allCases) { category in
                    CategoryChipView(
                        title: category.rawValue,
                        icon: category.systemIcon,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.vertical, 6)
        }
    }
}

