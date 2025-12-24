import SwiftUI

struct AppColors {
    static var background: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? .black : .white
        })
    }
    
    static var primaryText: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? .white : .black
        })
    }
    
    static func secondaryText(opacity: Double = 0.7) -> Color {
        Color(UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor.white.withAlphaComponent(opacity)
            } else {
                return UIColor.black.withAlphaComponent(opacity)
            }
        })
    }
    
    static func cardBackground(opacity: Double = 0.06) -> Color {
        Color(UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor.white.withAlphaComponent(opacity)
            } else {
                let grayValue = 0.95 + (opacity * 0.03)
                return UIColor(red: grayValue, green: grayValue, blue: min(grayValue + 0.02, 1.0), alpha: 1.0)
            }
        })
    }
    
    static func border(opacity: Double = 0.12) -> Color {
        Color(UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor.white.withAlphaComponent(opacity)
            } else {
                let grayValue = 0.88 + (opacity * 0.05)
                return UIColor(red: grayValue, green: grayValue, blue: min(grayValue + 0.02, 1.0), alpha: 1.0)
            }
        })
    }
    
    static var gradientStart: Color {
        Color(UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return .white
            } else {
                return UIColor(red: 0.88, green: 0.90, blue: 0.93, alpha: 1.0)
            }
        })
    }
    
    static var gradientMiddle: Color {
        Color(UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(red: 0.7, green: 0.7, blue: 0.75, alpha: 1.0)
            } else {
                return UIColor(red: 0.94, green: 0.95, blue: 0.97, alpha: 1.0)
            }
        })
    }
    
    static var gradientEnd: Color {
        Color(UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return .black
            } else {
                return .white
            }
        })
    }
    
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
