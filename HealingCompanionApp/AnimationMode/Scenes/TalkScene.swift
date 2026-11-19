import SwiftUI

struct TalkScene: View {
    let character: CompanionCharacter
    let message: String
    var mood: VariantMood = .active
    var customText: String? = nil
    let onComplete: () -> Void

    private var behavior: SceneBehavior { SceneBehavior.from(mood) }

    @State private var lean: Double = -6
    @State private var characterScale: CGFloat = 0.9
    @State private var bubbleScale: CGFloat = 0.01
    @State private var showMessage = false

    var body: some View {
        SceneStage(emotion: .talk, duration: behavior.duration + 0.5, onComplete: onComplete) {
            ZStack {
                ParticleEmitter(style: .softBubbles)

                if let customText, !customText.isEmpty {
                    VStack {
                        CustomTextBadge(text: customText)
                            .padding(.top, 70)
                        Spacer()
                    }
                }

                VStack(spacing: 30) {
                    Spacer()

                    if behavior.showBubble {
                        ZStack {
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .fill(.white.opacity(0.95))
                                .frame(maxWidth: 320)
                                .frame(height: 120)
                                .shadow(color: .black.opacity(0.12), radius: 10, y: 4)
                                .scaleEffect(bubbleScale)

                            if showMessage {
                                Text(message)
                                    .font(.title3)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 22)
                                    .transition(.opacity)
                            }
                        }
                        .padding(.horizontal, 28)
                    }

                    HealyAvatarView(emotion: .talk, size: 100)
                        .rotationEffect(.degrees(lean))
                        .scaleEffect(characterScale)

                    Spacer()
                }
            }
            .onAppear { runBeats() }
        }
    }

    private func runBeats() {
        withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
            lean = 8
            characterScale = 1.08
        }

        if behavior.showBubble {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7 + behavior.bubbleDelayOffset) {
                withAnimation(.spring(response: 0.55, dampingFraction: 0.55)) {
                    bubbleScale = 1.0
                }
                withAnimation(.easeIn(duration: 0.4).delay(0.3)) {
                    showMessage = true
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.5).repeatCount(3, autoreverses: true)) {
                characterScale = 1.12
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + behavior.duration - 1.1) {
            withAnimation(.easeIn(duration: 1.0)) {
                showMessage = false
                bubbleScale = 0.01
                characterScale = 0.95
            }
        }
    }
}
