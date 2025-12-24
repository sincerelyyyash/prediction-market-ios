import SwiftUI

struct AuthTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        ZStack(alignment: .leading) {
            TextField("", text: $text)
                .textInputAutocapitalization(.none)
                .keyboardType(keyboardType)
                .padding()
                .background(AppColors.cardBackground(opacity: 0.08))
                .cornerRadius(12)
                .foregroundColor(AppColors.primaryText)
                .font(.custom("DMMono-Regular", size: 18))
                .overlay(alignment: .leading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .foregroundColor(Color(UIColor { traitCollection in
                                if traitCollection.userInterfaceStyle == .dark {
                                    return UIColor.white.withAlphaComponent(0.6)
                                } else {
                                    return UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
                                }
                            }))
                            .font(.custom("DMMono-Regular", size: 18))
                            .padding(.horizontal, 16)
                            .allowsHitTesting(false)
                    }
                }
        }
    }
}

