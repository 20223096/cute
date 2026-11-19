import SwiftUI

struct BlanketView: View {
    var width: CGFloat = 260
    var height: CGFloat = 120
    var color: Color = Color(red: 0.85, green: 0.80, blue: 1.00)
    var stripeColor: Color = Color(red: 1.00, green: 0.88, blue: 0.95)

    var body: some View {
        ZStack(alignment: .top) {
            BlanketShape()
                .fill(
                    LinearGradient(
                        colors: [color, color.opacity(0.82)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .overlay(
                    BlanketShape()
                        .stroke(color.opacity(0.6), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)

            stripes
                .mask(BlanketShape())

            BlanketTrim()
                .fill(stripeColor)
                .frame(height: 12)
                .offset(y: 4)
        }
        .frame(width: width, height: height)
    }

    private var stripes: some View {
        VStack(spacing: 14) {
            ForEach(0..<3, id: \.self) { _ in
                Rectangle()
                    .fill(stripeColor.opacity(0.55))
                    .frame(height: 4)
            }
        }
        .padding(.top, 32)
        .frame(width: width, height: height, alignment: .top)
    }
}

struct PillowView: View {
    var width: CGFloat = 120
    var height: CGFloat = 40
    var color: Color = Color(red: 1.0, green: 0.95, blue: 0.92)

    var body: some View {
        RoundedRectangle(cornerRadius: height * 0.5, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [color, color.opacity(0.88)],
                    startPoint: .top, endPoint: .bottom
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: height * 0.5, style: .continuous)
                    .stroke(Color.pink.opacity(0.2), lineWidth: 1)
            )
            .frame(width: width, height: height)
            .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
    }
}

private struct BlanketShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let corner: CGFloat = 40
        path.move(to: CGPoint(x: 0, y: corner))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: corner),
            control: CGPoint(x: rect.midX, y: -corner * 0.3)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct BlanketTrim: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.maxY * 0.5))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY * 0.5),
            control: CGPoint(x: rect.midX, y: -rect.maxY * 0.2)
        )
        path.addQuadCurve(
            to: CGPoint(x: 0, y: rect.maxY * 0.5),
            control: CGPoint(x: rect.midX, y: rect.maxY * 1.2)
        )
        path.closeSubpath()
        return path
    }
}
