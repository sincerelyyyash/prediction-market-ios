import SwiftUI

struct OutcomeListView: View {
    let outcomes: [OutcomeMarket]
    let handleOpenOrderbook: (OutcomeMarket) -> Void
    let handleOpenYesOrderbook: (OutcomeMarket) -> Void
    let handleOpenNoOrderbook: (OutcomeMarket) -> Void
    let handleOpenYesTicket: (OutcomeMarket) -> Void
    let handleOpenNoTicket: (OutcomeMarket) -> Void

    var body: some View {
        LazyVStack(spacing: 10) {
            ForEach(outcomes) { outcome in
                OutcomeRowView(
                    outcome: outcome,
                    handleBuyYes: {
                        handleOpenYesTicket(outcome)
                    },
                    handleBuyNo: {
                        handleOpenNoTicket(outcome)
                    },
                    handleOpenOrderbook: {
                        handleOpenOrderbook(outcome)
                    }
                )
            }
        }
    }
}

