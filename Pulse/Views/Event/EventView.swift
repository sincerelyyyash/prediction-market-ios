import SwiftUI

struct EventView: View {
    let event: EventDetail

    @Environment(\.dismiss) private var dismiss
    @State private var showingOrderbookFor: OutcomeMarket?
    @State private var showingTicketConfig: OrderTicketConfig?
    @State private var orderbookInitialSide: MarketSideType = .yes

    var body: some View {
        GeometryReader { geo in
            ZStack {
                backgroundGradient(for: geo)
                ScrollView {
                    VStack(spacing: 16) {
                        EventTopBarView(handleDismiss: dismiss)
                            .padding(.horizontal, 16)
                            .padding(.top, 10)
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
                            },
                            handleOpenYesTicket: { outcome in
                                let config = OrderTicketConfig(
                                    outcome: outcome,
                                    side: .yes,
                                    isBuy: true,
                                    initialPrice: outcome.yes.price
                                )
                                showingTicketConfig = config
                            },
                            handleOpenNoTicket: { outcome in
                                let config = OrderTicketConfig(
                                    outcome: outcome,
                                    side: .no,
                                    isBuy: true,
                                    initialPrice: outcome.no.price
                                )
                                showingTicketConfig = config
                            }
                        )
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                }
                .sheet(item: $showingOrderbookFor) { outcome in
                    OrderbookView(
                        eventID: event.id,
                        outcome: outcome,
                        initialSide: orderbookInitialSide
                    )
                        .preferredColorScheme(.dark)
                        .presentationContentInteraction(.scrolls)
                        .presentationBackgroundInteraction(.enabled)
                        .presentationDragIndicator(.visible)
                        .presentationDetents([.fraction(0.8), .large])
                        .presentationBackground(.black)
                }
                .sheet(item: $showingTicketConfig) { config in
                    OrderTicketView(
                        config: config,
                        handleDismiss: {
                            showingTicketConfig = nil
                        }
                    )
                    .preferredColorScheme(.dark)
                    .presentationDetents([.fraction(0.55), .large])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(.black)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
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
}

#Preview {
    let sample = Constants.placeholderEventDetails.first!
    return EventView(event: sample)
        .preferredColorScheme(.dark)
}
