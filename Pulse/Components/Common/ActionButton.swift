import SwiftUI

struct ActionButton: View {
    enum Style {
        case yes
        case no

        var background: Color {
            switch self {
            case .yes: return Color.green.opacity(0.22)
            case .no: return Color.red.opacity(0.22)
            }
        }

        var border: Color {
            switch self {
            case .yes: return Color.green.opacity(0.35)
            case .no: return Color.red.opacity(0.35)
            }
        }

        var text: Color {
            switch self {
            case .yes: return .green
            case .no: return .red
            }
        }
    }

    let title: String
    let style: Style
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(style.text)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(style.background)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(style.border, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

