import SwiftUI

#if canImport(UIKit)

/// 홈·위젯용 정적 포트레이트 + 감정별 `MotionStyle` + 살짝 숨 쉬는 모션.
struct HomeCharacterPortraitView: View {
    let reaction: CompanionReaction
    var motion: MotionStyle
    var size: CGFloat

    private var imageName: String { "home_mood_\(reaction.homeMoodImageIndex)" }

    var body: some View {
        HealyBundleUIImageView(name: imageName, contentMode: .scaleAspectFit)
            .frame(width: size, height: size)
            .modifier(MotionModifier(style: motion))
            .modifier(PortraitLifeModifier())
    }
}

private struct PortraitLifeModifier: ViewModifier {
    @State private var phase = false

    func body(content: Content) -> some View {
        content
            .offset(y: phase ? 2 : -2)
            .scaleEffect(phase ? 1.025 : 0.99)
            .animation(.easeInOut(duration: 2.35).repeatForever(autoreverses: true), value: phase)
            .onAppear { phase = true }
    }
}

#endif
