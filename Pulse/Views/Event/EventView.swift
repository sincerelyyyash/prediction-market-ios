import SwiftUI

struct EventView: View {
    let event: EventDetail

    @Environment(\.dismiss) private var dismiss
    @State private var showingOrderbookFor: OutcomeMarket?
    @State private var orderbookInitialSide: MarketSideType = .yes

    var body: some View {
        GeometryReader { geo in
            ZStack {
                backgroundGradient(for: geo)
                ScrollView {
                    VStack(spacing: 16) {
                        Spacer()
                            .frame(height: 60)
                        EventHeroImageView(
                            imageName: event.imageName,
                            imgUrl: event.imgUrl,
                            availableWidth: geo.size.width
                        )
                        .padding(.horizontal, 16)
                        EventMetaSectionView(event: event)
                            .padding(.horizontal, 16)
                        EventDescriptionView(descriptionText: event.description)
                            .padding(.horizontal, 16)
                        OutcomeListView(
                            outcomes: event.outcomes,
                            handleOpenOrderbook: { outcome in
                                orderbookInitialSide = .yes
                                showingOrderbookFor = outcome
                            },
                            handleOpenYesOrderbook: { outcome in
                                orderbookInitialSide = .yes
                                showingOrderbookFor = outcome
                            },
                            handleOpenNoOrderbook: { outcome in
                                orderbookInitialSide = .no
                                showingOrderbookFor = outcome
                            }
                        )
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                }
            }
            .overlay(alignment: .topLeading) {
                EventTopBarView(handleDismiss: dismiss)
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
            }
            .sheet(item: $showingOrderbookFor) { outcome in
                OrderbookView(
                    eventID: event.id,
                    outcome: outcome,
                    initialSide: orderbookInitialSide
                )
                    .presentationContentInteraction(.scrolls)
                    .presentationBackgroundInteraction(.enabled)
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.fraction(0.95), .large])
                    .presentationBackground(AppColors.background)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private func backgroundGradient(for geo: GeometryProxy) -> some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            RadialGradient(
                gradient: Gradient(stops: [
                    .init(color: AppColors.gradientStart, location: 0.0),
                    .init(color: AppColors.gradientMiddle, location: 0.15),
                    .init(color: AppColors.gradientEnd, location: 0.4)
                ]),
                center: .top,
                startRadius: 0,
                endRadius: max(geo.size.width, geo.size.height) * 0.9
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
    }
}

#Preview {
    let sample = Constants.placeholderEventDetails.first!
    return EventView(event: sample)
}
