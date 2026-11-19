import SwiftUI

struct MotionModifier: ViewModifier {
    let style: MotionStyle

    @State private var breathe = false
    @State private var droop = false
    @State private var fadeBreath = false
    @State private var shake = false
    @State private var blink = false
    @State private var lean = false

    func body(content: Content) -> some View {
        switch style {
        case .slowDroop:
            content
                .rotationEffect(.degrees(droop ? 6 : -6))
                .offset(y: droop ? 3 : -3)
                .animation(
                    .easeInOut(duration: 1.8).repeatForever(autoreverses: true),
                    value: droop
                )
                .onAppear { droop = true }

        case .slowFade:
            content
                .opacity(fadeBreath ? 0.55 : 1.0)
                .scaleEffect(fadeBreath ? 0.95 : 1.05)
                .animation(
                    .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                    value: fadeBreath
                )
                .onAppear { fadeBreath = true }

        case .fastShake:
            content
                .offset(x: shake ? 8 : -8)
                .rotationEffect(.degrees(shake ? 3 : -3))
                .animation(
                    .linear(duration: 0.07).repeatForever(autoreverses: true),
                    value: shake
                )
                .onAppear { shake = true }

        case .minimal:
            content
                .opacity(blink ? 0.55 : 1.0)
                .animation(
                    .easeInOut(duration: 0.18)
                        .repeatForever(autoreverses: true)
                        .delay(2.4),
                    value: blink
                )
                .onAppear { blink = true }

        case .leanBounce:
            content
                .rotationEffect(.degrees(lean ? 6 : -2))
                .scaleEffect(lean ? 1.08 : 0.98)
                .offset(y: lean ? -6 : 2)
                .animation(
                    .spring(response: 0.5, dampingFraction: 0.55)
                        .repeatForever(autoreverses: true),
                    value: lean
                )
                .onAppear { lean = true }
        }
    }
}
