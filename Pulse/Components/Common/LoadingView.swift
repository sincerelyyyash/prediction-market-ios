import SwiftUI

struct LoadingView: View {
    let message: String?
    let size: LoadingSize
    
    enum LoadingSize {
        case small
        case medium
        case large
        
        var spinnerSize: CGFloat {
            switch self {
            case .small: return 20
            case .medium: return 32
            case .large: return 48
            }
        }
        
        var strokeWidth: CGFloat {
            switch self {
            case .small: return 2
            case .medium: return 3
            case .large: return 4
            }
        }
    }
    
    init(message: String? = nil, size: LoadingSize = .medium) {
        self.message = message
        self.size = size
    }
    
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 0.8
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                AppColors.secondaryText(opacity: 0.3),
                                AppColors.secondaryText(opacity: 0.1),
                                AppColors.secondaryText(opacity: 0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: size.strokeWidth
                    )
                    .frame(width: size.spinnerSize, height: size.spinnerSize)
                    .scaleEffect(scale)
                    .opacity(0.6)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        LinearGradient(
                            colors: [
                                AppColors.secondaryText(opacity: 0.9),
                                AppColors.secondaryText(opacity: 0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: size.strokeWidth, lineCap: .round)
                    )
                    .frame(width: size.spinnerSize, height: size.spinnerSize)
                    .rotationEffect(.degrees(rotation))
            }
            
            if let message = message {
                Text(message)
                    .font(.dmMonoRegular(size: 14))
                    .foregroundColor(AppColors.secondaryText(opacity: 0.7))
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
        }
        .onAppear {
            withAnimation(
                Animation
                    .linear(duration: 1.0)
                    .repeatForever(autoreverses: false)
            ) {
                rotation = 360
            }
            
            withAnimation(
                Animation
                    .easeInOut(duration: 1.2)
                    .repeatForever(autoreverses: true)
            ) {
                scale = 1.1
            }
        }
    }
}

struct FullScreenLoadingView: View {
    let message: String?
    
    init(message: String? = nil) {
        self.message = message
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            LoadingView(message: message, size: .large)
        }
    }
}

struct InlineLoadingView: View {
    let message: String?
    let color: Color
    
    init(message: String? = nil, color: Color = AppColors.primaryText) {
        self.message = message
        self.color = color
    }
    
    @State private var rotation: Double = 0
    
    var body: some View {
        Group {
            if message != nil {
                LoadingView(message: message, size: .small)
            } else {
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        color.opacity(0.8),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                    )
                    .frame(width: 16, height: 16)
                    .rotationEffect(.degrees(rotation))
                    .onAppear {
                        withAnimation(
                            Animation
                                .linear(duration: 0.8)
                                .repeatForever(autoreverses: false)
                        ) {
                            rotation = 360
                        }
                    }
            }
        }
    }
}

