import SwiftUI

struct SoftSparkleView: View {
    var count: Int = 10
    var tint: Color = .white

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<count, id: \.self) { i in
                    SparkleDot(
                        position: position(for: i, in: geo.size),
                        delay: Double(i) * 0.25,
                        tint: tint
                    )
                }
            }
        }
    }

    private func position(for i: Int, in size: CGSize) -> CGPoint {
        let angle = Double(i) / Double(count) * 2 * .pi
        let jitter = Double.random(in: 0.7...1.15)
        let radiusX = size.width * 0.38 * jitter
        let radiusY = size.height * 0.32 * jitter
        return CGPoint(
            x: size.width / 2 + CGFloat(cos(angle)) * radiusX,
            y: size.height / 2 + CGFloat(sin(angle)) * radiusY
        )
    }
}

private struct SparkleDot: View {
    let position: CGPoint
    let delay: Double
    let tint: Color

    @State private var animate = false

    var body: some View {
        Image(systemName: "sparkle")
            .font(.system(size: animate ? 12 : 4, weight: .light))
            .foregroundStyle(tint.opacity(animate ? 0 : 0.85))
            .rotationEffect(.degrees(animate ? 40 : 0))
            .position(position)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2.2)
                        .delay(delay)
                        .repeatForever(autoreverses: false)
                ) {
                    animate = true
                }
            }
    }
}
