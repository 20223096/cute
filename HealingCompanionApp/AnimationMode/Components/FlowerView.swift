import SwiftUI

struct FlowerView: View {
    var size: CGFloat = 48
    var petalColor: Color = Color(red: 1.00, green: 0.78, blue: 0.88)
    var centerColor: Color = Color(red: 1.00, green: 0.88, blue: 0.55)
    var stemColor: Color = Color(red: 0.55, green: 0.78, blue: 0.55)

    @State private var wobble = false

    var body: some View {
        ZStack(alignment: .top) {
            StemPath()
                .stroke(stemColor, style: StrokeStyle(lineWidth: size * 0.06, lineCap: .round))
                .frame(width: size * 0.4, height: size * 0.9)
                .offset(y: size * 0.35)

            leaf
                .offset(x: size * 0.15, y: size * 0.75)
                .rotationEffect(.degrees(wobble ? 6 : -4), anchor: .bottomLeading)
                .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true), value: wobble)

            flowerHead
                .rotationEffect(.degrees(wobble ? 3 : -3))
                .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: wobble)
        }
        .frame(width: size, height: size * 1.2)
        .onAppear { wobble = true }
    }

    private var flowerHead: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { i in
                Circle()
                    .fill(petalColor)
                    .frame(width: size * 0.38, height: size * 0.48)
                    .offset(y: -size * 0.2)
                    .rotationEffect(.degrees(Double(i) * 60))
            }
            Circle()
                .fill(centerColor)
                .frame(width: size * 0.25, height: size * 0.25)
                .overlay(
                    Circle()
                        .stroke(centerColor.opacity(0.6), lineWidth: 1)
                )
        }
        .frame(width: size, height: size)
    }

    private var leaf: some View {
        LeafShape()
            .fill(stemColor.opacity(0.85))
            .frame(width: size * 0.28, height: size * 0.16)
            .rotationEffect(.degrees(-20), anchor: .bottomLeading)
    }
}

private struct StemPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control: CGPoint(x: rect.midX + rect.width * 0.4, y: rect.midY)
        )
        return path
    }
}

private struct LeafShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: 0),
            control: CGPoint(x: rect.maxX * 0.3, y: 0)
        )
        path.addQuadCurve(
            to: CGPoint(x: 0, y: rect.maxY),
            control: CGPoint(x: rect.maxX * 0.7, y: rect.maxY)
        )
        path.closeSubpath()
        return path
    }
}
