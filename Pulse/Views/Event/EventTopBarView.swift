import SwiftUI

struct EventTopBarView: View {
    let handleDismiss: DismissAction

    var body: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.slideTransition) {
                    handleDismiss()
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.dmMonoMedium(size: 17))
                    .foregroundColor(AppColors.primaryText)
                    .padding(10)
                    .background(AppColors.cardBackground(opacity: 0.08))
                    .clipShape(Circle())
            }
            Spacer()
        }
    }
}

