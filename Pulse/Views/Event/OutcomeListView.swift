import SwiftUI

struct OutcomeListView: View {
    let outcomes: [OutcomeMarket]
    let handleOpenOrderbook: (OutcomeMarket) -> Void

    var body: some View {
        LazyVStack(spacing: 10) {
            ForEach(outcomes) { outcome in
                OutcomeRowView(
                    outcome: outcome,
                    handleBuyYes: { /* hook yes */ },
                    handleBuyNo: { /* hook no */ },
                    handleOpenOrderbook: {
                        handleOpenOrderbook(outcome)
                    }
                )
            }
        }
    }
}

