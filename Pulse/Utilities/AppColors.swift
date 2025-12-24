import SwiftUI

struct AppColors {
    /// Primary background color - black in dark mode, white in light mode
    static var background: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? .black : .white
        })
    }
    
    /// Primary text color - white in dark mode, black in light mode
    static var primaryText: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? .white : .black
        })
    }
    
    /// Secondary text color with opacity
    static func secondaryText(opacity: Double = 0.7) -> Color {
        Color(UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor.white.withAlphaComponent(opacity)
            } else {
                return UIColor.black.withAlphaComponent(opacity)
            }
        })
    }
    
    /// Card background color with opacity
    static func cardBackground(opacity: Double = 0.06) -> Color {
        Color(UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor.white.withAlphaComponent(opacity)
            } else {
                // In light mode, use a very light gray for subtle contrast
                // Scale the gray intensity based on opacity for variety
                let grayValue = 0.95 + (opacity * 0.03) // Range from 0.95 to 0.98
                return UIColor(red: grayValue, green: grayValue, blue: min(grayValue + 0.02, 1.0), alpha: 1.0)
            }
        })
    }
    
    /// Border color with opacity
    static func border(opacity: Double = 0.12) -> Color {
        Color(UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor.white.withAlphaComponent(opacity)
            } else {
                // In light mode, use a light gray border
                // Scale the gray intensity based on opacity
                let grayValue = 0.88 + (opacity * 0.05) // Range from 0.88 to 0.93
                return UIColor(red: grayValue, green: grayValue, blue: min(grayValue + 0.02, 1.0), alpha: 1.0)
            }
        })
    }
    
    /// Gradient start color (top of radial gradient)
    static var gradientStart: Color {
        Color(UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return .white
            } else {
                // Light mode: more visible light gray-blue at top
                return UIColor(red: 0.88, green: 0.90, blue: 0.93, alpha: 1.0)
            }
        })
    }
    
    /// Gradient middle color
    static var gradientMiddle: Color {
        Color(UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(red: 0.7, green: 0.7, blue: 0.75, alpha: 1.0)
            } else {
                // Light mode: medium light gray for visible transition
                return UIColor(red: 0.94, green: 0.95, blue: 0.97, alpha: 1.0)
            }
        })
    }
    
    /// Gradient end color (bottom of radial gradient)
    static var gradientEnd: Color {
        Color(UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return .black
            } else {
                // Light mode: pure white at bottom
                return .white
            }
        })
    }
    
    /// Overlay background for loading states
    static func overlayBackground(opacity: Double = 0.3) -> Color {
        Color(UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor.black.withAlphaComponent(opacity)
            } else {
                return UIColor.white.withAlphaComponent(opacity)
            }
        })
    }
}
