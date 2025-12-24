import SwiftUI

struct NetworkErrorView: View {
    let message: String
    let onRetry: (() -> Void)?
    
    init(message: String, onRetry: (() -> Void)? = nil) {
        self.message = message
        self.onRetry = onRetry
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "wifi.slash")
                    .font(.system(size: 60))
                    .foregroundColor(AppColors.secondaryText(opacity: 0.6))
                
                Text(message)
                    .font(.custom("DMMono-Medium", size: 18))
                    .foregroundColor(AppColors.primaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                if let onRetry {
                    Button(action: onRetry) {
                        Text("Retry")
                            .font(.custom("DMMono-Medium", size: 16))
                            .foregroundColor(AppColors.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppColors.primaryText)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 8)
                }
            }
        }
    }
}

