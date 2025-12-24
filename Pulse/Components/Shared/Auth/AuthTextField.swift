import SwiftUI

struct AuthTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(AppColors.secondaryText(opacity: 0.6))
                    .font(.custom("DMMono-Regular", size: 18))
                    .padding(.horizontal, 16)
            }
            TextField("", text: $text)
                .textInputAutocapitalization(.none)
                .keyboardType(keyboardType)
                .padding()
                .background(AppColors.cardBackground(opacity: 0.08))
                .cornerRadius(12)
                .foregroundColor(AppColors.primaryText)
                .font(.custom("DMMono-Regular", size: 18))
        }
    }
}

