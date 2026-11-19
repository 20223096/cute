import SwiftUI

enum ComfortPose {
    case concerned
    case gentle
}

enum CharacterAccessory {
    case none
    case tissue
    case flower
}

struct ComfortCharacterView: View {
    var size: CGFloat = 170
    var bodyColor: Color = Color(red: 1.00, green: 0.78, blue: 0.82)
    var pose: ComfortPose = .concerned
    var armExtension: CGFloat = 0
    var accessory: CharacterAccessory = .none

    @State private var breathe = false

    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color.black.opacity(0.07))
                .frame(width: size * 0.78, height: size * 0.12)
                .offset(y: size * 0.55)
                .blur(radius: 2)

            bodyBlob
                .scaleEffect(breathe ? 1.025 : 0.985)
                .animation(
                    .easeInOut(duration: 2.1).repeatForever(autoreverses: true),
                    value: breathe
                )
                .onAppear { breathe = true }

            cheeks
                .offset(y: size * 0.02)
                .opacity(0.9)

            face
                .offset(y: -size * 0.05)

            leftArm
                .offset(x: -size * 0.28, y: size * 0.15)

            rightArmWithAccessory
                .offset(
                    x: size * 0.28 + armExtension * size * 0.18,
                    y: size * 0.12 - armExtension * size * 0.05
                )
                .rotationEffect(
                    .degrees(-25 - Double(armExtension) * 30),
                    anchor: .topLeading
                )
                .animation(.spring(response: 0.7, dampingFraction: 0.75), value: armExtension)
        }
        .frame(width: size, height: size * 1.15)
    }

    // MARK: - Body blob

    private var bodyBlob: some View {
        ZStack {
            BodyBlob()
                .fill(bodyColor)
                .frame(width: size, height: size * 1.05)

            BodyBlob()
                .stroke(bodyColor.opacity(0.55), lineWidth: 1)
                .frame(width: size, height: size * 1.05)
        }
    }

    private var cheeks: some View {
        HStack(spacing: size * 0.48) {
            Circle()
                .fill(Color.pink.opacity(0.35))
                .frame(width: size * 0.14, height: size * 0.09)
                .blur(radius: 2)
            Circle()
                .fill(Color.pink.opacity(0.35))
                .frame(width: size * 0.14, height: size * 0.09)
                .blur(radius: 2)
        }
    }

    // MARK: - Face

    private var face: some View {
        VStack(spacing: size * 0.05) {
            HStack(spacing: size * 0.22) {
                eye
                eye
            }
            mouth
        }
    }

    @ViewBuilder
    private var eye: some View {
        switch pose {
        case .concerned:
            Capsule()
                .fill(Color.black.opacity(0.78))
                .frame(width: size * 0.06, height: size * 0.09)
        case .gentle:
            ClosedEyeArc()
                .stroke(Color.black.opacity(0.72), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .frame(width: size * 0.1, height: size * 0.05)
        }
    }

    @ViewBuilder
    private var mouth: some View {
        switch pose {
        case .concerned:
            ConcernedMouth()
                .stroke(Color.black.opacity(0.6), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .frame(width: size * 0.16, height: size * 0.06)
        case .gentle:
            GentleSmile()
                .stroke(Color.black.opacity(0.6), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .frame(width: size * 0.16, height: size * 0.06)
        }
    }

    // MARK: - Arms

    private var leftArm: some View {
        Capsule()
            .fill(bodyColor)
            .frame(width: size * 0.16, height: size * 0.3)
            .rotationEffect(.degrees(22), anchor: .top)
    }

    private var rightArmWithAccessory: some View {
        ZStack(alignment: .bottom) {
            Capsule()
                .fill(bodyColor)
                .frame(width: size * 0.16, height: size * 0.34)

            switch accessory {
            case .none:
                EmptyView()
            case .tissue:
                TissueView(size: size * 0.3)
                    .offset(y: size * 0.12)
                    .transition(.scale.combined(with: .opacity))
            case .flower:
                FlowerView(size: size * 0.38)
                    .offset(y: size * 0.14)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
}

// MARK: - Shapes

private struct BodyBlob: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.move(to: CGPoint(x: w * 0.5, y: 0))
        path.addCurve(
            to: CGPoint(x: w, y: h * 0.55),
            control1: CGPoint(x: w * 0.98, y: h * 0.05),
            control2: CGPoint(x: w * 1.02, y: h * 0.35)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: h),
            control1: CGPoint(x: w * 0.98, y: h * 0.92),
            control2: CGPoint(x: w * 0.78, y: h)
        )
        path.addCurve(
            to: CGPoint(x: 0, y: h * 0.55),
            control1: CGPoint(x: w * 0.22, y: h),
            control2: CGPoint(x: w * 0.02, y: h * 0.92)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: 0),
            control1: CGPoint(x: -w * 0.02, y: h * 0.35),
            control2: CGPoint(x: w * 0.02, y: h * 0.05)
        )
        path.closeSubpath()
        return path
    }
}

private struct ConcernedMouth: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY),
            control: CGPoint(x: rect.midX, y: -rect.maxY * 0.3)
        )
        return path
    }
}

private struct GentleSmile: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: 0),
            control: CGPoint(x: rect.midX, y: rect.maxY * 1.8)
        )
        return path
    }
}

private struct ClosedEyeArc: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.midY),
            control: CGPoint(x: rect.midX, y: -rect.maxY)
        )
        return path
    }
}
