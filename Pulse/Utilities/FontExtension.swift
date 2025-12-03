import SwiftUI

extension Font {
    /// DM Mono Regular - Default body text, labels, regular content
    static func dmMonoRegular(size: CGFloat) -> Font {
        .custom("DMMono-Regular", size: size)
    }
    
    /// DM Mono Light - Large display text, subtle text, elegant headings
    static func dmMonoLight(size: CGFloat) -> Font {
        .custom("DMMono-Light", size: size)
    }
    
    /// DM Mono Medium - Headings, buttons, emphasis, important text
    static func dmMonoMedium(size: CGFloat) -> Font {
        .custom("DMMono-Medium", size: size)
    }
    
    /// DM Mono Regular Italic - Emphasized regular text
    static func dmMonoRegularItalic(size: CGFloat) -> Font {
        .custom("DMMono-Italic", size: size)
    }
    
    /// DM Mono Light Italic - Elegant emphasized text
    static func dmMonoLightItalic(size: CGFloat) -> Font {
        .custom("DMMono-LightItalic", size: size)
    }
    
    /// DM Mono Medium Italic - Strong emphasized text
    static func dmMonoMediumItalic(size: CGFloat) -> Font {
        .custom("DMMono-MediumItalic", size: size)
    }
}

