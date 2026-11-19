import SwiftUI

struct CustomTextBadge: View {
    let text: String
    var tint: Color = .white

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "quote.opening")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(tint.opacity(0.75))
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(tint.opacity(0.9))
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule().fill(Color.black.opacity(0.18))
        )
    }
}
