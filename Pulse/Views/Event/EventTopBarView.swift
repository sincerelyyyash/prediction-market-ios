import SwiftUI

struct EventTopBarView: View {
    let handleDismiss: DismissAction

    var body: some View {
        HStack(spacing: 12) {
            Button {
                handleDismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.dmMonoMedium(size: 17))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Circle())
            }
            Spacer()
        }
    }
}

