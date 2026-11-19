import SwiftUI

struct EnvelopeBodyShape: Shape {
    var cornerRadius: CGFloat = 14
    func path(in rect: CGRect) -> Path {
        Path(roundedRect: rect, cornerRadius: cornerRadius)
    }
}

struct EnvelopeFlapShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        p.closeSubpath()
        return p
    }
}

struct EnvelopeCreasesShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.midX, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        return p
    }
}

struct EnvelopeView: View {
    var primaryColor: Color
    var secondaryColor: Color
    var sealSymbol: String?
    /// 힐리 얼굴 봉인 — `nil`이면 `sealSymbol` 또는 비움
    var sealEmotion: EmotionType?
    var size: CGSize = CGSize(width: 220, height: 150)
    var flapOpen: Bool = false
    var flapProgress: Double = 0

    var body: some View {
        ZStack {
            EnvelopeBodyShape(cornerRadius: 14)
                .fill(
                    LinearGradient(
                        colors: [primaryColor, secondaryColor],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    EnvelopeCreasesShape()
                        .stroke(Color.white.opacity(0.55), lineWidth: 1.3)
                )
                .shadow(color: .black.opacity(0.15), radius: 10, y: 4)

            ZStack {
                EnvelopeFlapShape()
                    .fill(
                        LinearGradient(
                            colors: [primaryColor.opacity(0.95), secondaryColor.opacity(0.95)],
                            startPoint: .bottom, endPoint: .top
                        )
                    )
                    .overlay(
                        EnvelopeFlapShape()
                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    )
            }
            .frame(width: size.width, height: size.height * 0.55)
            .rotation3DEffect(
                .degrees(flapOpen ? -170 * flapProgress : 0),
                axis: (x: 1, y: 0, z: 0),
                anchor: .top,
                perspective: 0.6
            )
            .offset(y: -size.height * 0.225)

            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.95))
                    .frame(width: size.height * 0.32, height: size.height * 0.32)
                    .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
                if let sealEmotion {
                    HealyAvatarView(emotion: sealEmotion, size: size.height * 0.34)
                } else if let sealSymbol = sealSymbol {
                    Image(systemName: sealSymbol)
                        .font(.system(size: size.height * 0.16, weight: .bold))
                        .foregroundStyle(primaryColor.opacity(0.85))
                }
            }
            .offset(y: size.height * 0.08)
            .opacity(flapOpen ? max(0, 1 - flapProgress * 1.4) : 1)
        }
        .frame(width: size.width, height: size.height)
    }
}
