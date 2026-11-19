import SwiftUI

struct SandbagView: View {
    var width: CGFloat = 110
    var height: CGFloat = 190
    var bagColor: Color = Color(red: 0.82, green: 0.42, blue: 0.36)
    var strapColor: Color = Color(red: 0.58, green: 0.28, blue: 0.24)

    var body: some View {
        VStack(spacing: 0) {
            ChainLine()
                .stroke(Color.gray.opacity(0.7), style: StrokeStyle(lineWidth: 2.5, dash: [3, 3]))
                .frame(width: 4, height: height * 0.18)

            ZStack {
                RoundedRectangle(cornerRadius: width * 0.32, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [bagColor, bagColor.opacity(0.85)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: width, height: height * 0.82)
                    .shadow(color: .black.opacity(0.18), radius: 6, y: 4)

                Rectangle()
                    .fill(strapColor)
                    .frame(width: width * 1.04, height: 6)
                    .offset(y: -height * 0.28)

                Rectangle()
                    .fill(strapColor)
                    .frame(width: width * 1.04, height: 6)
                    .offset(y: height * 0.28)

                Rectangle()
                    .fill(strapColor.opacity(0.65))
                    .frame(width: width, height: 2)

                Text("★")
                    .font(.system(size: width * 0.22, weight: .heavy))
                    .foregroundStyle(.white.opacity(0.85))
                    .offset(y: -height * 0.02)
            }
        }
        .frame(width: width * 1.1, height: height)
    }
}

private struct ChainLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: 0))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}
