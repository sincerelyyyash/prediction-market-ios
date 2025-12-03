import SwiftUI

struct ProbabilityPillView: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text("\(label) \(percentageText)")
                .font(.dmMonoMedium(size: 12))
        }
        .foregroundColor(.white)
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var percentageText: String {
        "\(Int((value * 100).rounded()))%"
    }
}

