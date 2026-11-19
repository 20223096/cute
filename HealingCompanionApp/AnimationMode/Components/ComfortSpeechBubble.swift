import SwiftUI

struct ComfortSpeechBubble: View {
    let text: String
    var tailOffsetX: CGFloat = -40

    var body: some View {
        VStack(spacing: -1) {
            Text(text)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(Color.black.opacity(0.75))
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.1), radius: 10, y: 4)
                )

            BubbleTail()
                .fill(.white)
                .frame(width: 18, height: 12)
                .offset(x: tailOffsetX)
                .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
        }
    }
}

private struct BubbleTail: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX - rect.width * 0.3, y: 0))
        path.addLine(to: CGPoint(x: rect.midX + rect.width * 0.35, y: 0))
        path.addLine(to: CGPoint(x: rect.midX - rect.width * 0.1, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
