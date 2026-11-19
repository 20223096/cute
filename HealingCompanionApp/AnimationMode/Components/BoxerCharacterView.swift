import SwiftUI

enum BoxerPose {
    case ready
    case punch
}

struct BoxerCharacterView: View {
    var size: CGFloat = 170
    var bodyColor: Color = Color(red: 1.00, green: 0.76, blue: 0.72)
    var gloveColor: Color = Color(red: 0.88, green: 0.30, blue: 0.32)
    var pose: BoxerPose = .ready

    @State private var breathe = false

    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color.black.opacity(0.08))
                .frame(width: size * 0.78, height: size * 0.12)
                .offset(y: size * 0.55)
                .blur(radius: 2)

            bodyBlob
                .scaleEffect(breathe ? 1.02 : 0.99)
                .animation(
                    .easeInOut(duration: 0.9).repeatForever(autoreverses: true),
                    value: breathe
                )
                .onAppear { breathe = true }

            face
                .offset(y: -size * 0.06)

            leftGlove
                .offset(
                    x: pose == .punch ? -size * 0.22 : -size * 0.34,
                    y: pose == .punch ? size * 0.22 : size * 0.18
                )
                .animation(.spring(response: 0.25, dampingFraction: 0.55), value: pose)

            rightGlove
                .offset(
                    x: pose == .punch ? size * 0.52 : size * 0.34,
                    y: pose == .punch ? size * 0.08 : size * 0.18
                )
                .scaleEffect(pose == .punch ? 1.18 : 1.0)
                .animation(.spring(response: 0.22, dampingFraction: 0.5), value: pose)
        }
        .frame(width: size, height: size * 1.15)
    }

    private var bodyBlob: some View {
        Ellipse()
            .fill(
                LinearGradient(
                    colors: [bodyColor, bodyColor.opacity(0.88)],
                    startPoint: .top, endPoint: .bottom
                )
            )
            .frame(width: size, height: size * 1.05)
    }

    private var face: some View {
        VStack(spacing: size * 0.05) {
            HStack(spacing: size * 0.2) {
                determinedEye
                determinedEye
            }
            determinedMouth
                .frame(width: size * 0.18, height: size * 0.06)
        }
    }

    private var determinedEye: some View {
        DeterminedEye()
            .stroke(Color.black.opacity(0.82), style: StrokeStyle(lineWidth: 2.2, lineCap: .round))
            .frame(width: size * 0.12, height: size * 0.06)
    }

    private var determinedMouth: some View {
        Capsule()
            .fill(Color.black.opacity(0.65))
            .frame(width: size * 0.12, height: size * 0.035)
    }

    private var leftGlove: some View {
        GloveShape()
            .fill(gloveColor)
            .overlay(
                GloveShape()
                    .stroke(gloveColor.opacity(0.7), lineWidth: 1)
            )
            .frame(width: size * 0.28, height: size * 0.28)
    }

    private var rightGlove: some View {
        GloveShape()
            .fill(gloveColor)
            .overlay(
                GloveShape()
                    .stroke(gloveColor.opacity(0.7), lineWidth: 1)
            )
            .frame(width: size * 0.3, height: size * 0.3)
    }
}

private struct DeterminedEye: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX * 0.55, y: 0))
        path.move(to: CGPoint(x: rect.maxX * 0.45, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        return path
    }
}

private struct GloveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.move(to: CGPoint(x: w * 0.12, y: h * 0.3))
        path.addQuadCurve(
            to: CGPoint(x: w * 0.88, y: h * 0.25),
            control: CGPoint(x: w * 0.5, y: -h * 0.08)
        )
        path.addQuadCurve(
            to: CGPoint(x: w, y: h * 0.78),
            control: CGPoint(x: w * 1.05, y: h * 0.5)
        )
        path.addQuadCurve(
            to: CGPoint(x: w * 0.5, y: h),
            control: CGPoint(x: w * 0.85, y: h)
        )
        path.addQuadCurve(
            to: CGPoint(x: 0, y: h * 0.82),
            control: CGPoint(x: w * 0.1, y: h)
        )
        path.addQuadCurve(
            to: CGPoint(x: w * 0.12, y: h * 0.3),
            control: CGPoint(x: -w * 0.05, y: h * 0.55)
        )
        path.closeSubpath()
        return path
    }
}
