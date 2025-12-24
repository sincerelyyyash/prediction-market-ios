import SwiftUI

extension Animation {
    static var slideTransition: Animation {
        .easeInOut(duration: 0.3)
    }
    
    static var fadeTransition: Animation {
        .easeInOut(duration: 0.25)
    }
}

extension AnyTransition {
    static var slideFromTrailing: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
    
    static var slideFromLeading: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .leading).combined(with: .opacity),
            removal: .move(edge: .trailing).combined(with: .opacity)
        )
    }
    
    static var slideFromBottom: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        )
    }
    
    static var fadeTransition: AnyTransition {
        .opacity.combined(with: .scale(scale: 0.95))
    }
}

