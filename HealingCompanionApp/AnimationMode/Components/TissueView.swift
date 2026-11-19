import SwiftUI

struct TissueView: View {
    var size: CGFloat = 40
    var tint: Color = Color(red: 1.0, green: 0.98, blue: 0.98)

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.18, style: .continuous)
                .fill(tint)
                .shadow(color: .black.opacity(0.08), radius: 3, y: 1)

            RoundedRectangle(cornerRadius: size * 0.18, style: .continuous)
                .stroke(Color.pink.opacity(0.25), lineWidth: 1)

            Path { path in
                path.move(to: CGPoint(x: size * 0.22, y: size * 0.32))
                path.addQuadCurve(
                    to: CGPoint(x: size * 0.78, y: size * 0.42),
                    control: CGPoint(x: size * 0.5, y: size * 0.16)
                )
            }
            .stroke(Color.pink.opacity(0.18), lineWidth: 1.2)
            .frame(width: size, height: size)

            Circle()
                .fill(Color.pink.opacity(0.35))
                .frame(width: size * 0.08, height: size * 0.08)
                .offset(x: size * 0.22, y: size * 0.22)
        }
        .frame(width: size, height: size)
    }
}
