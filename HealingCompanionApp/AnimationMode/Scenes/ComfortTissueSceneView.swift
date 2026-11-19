import SwiftUI

/// 😭 "힘들어" — 일몰 바다 배경 전체 + 뗏목 + 말풍선.
struct ComfortTissueSceneView: View {
    let character: CompanionCharacter
    let message: String
    var mood: VariantMood = .active
    var customText: String? = nil
    let onComplete: () -> Void

    private var behavior: SceneBehavior { SceneBehavior.from(mood) }
    /// 10초 모션 이후 여유 + 말풍선
    private var sceneDuration: TimeInterval { max(behavior.duration, 14) }
    private let motionDuration: TimeInterval = 10

    @State private var epoch = Date()
    @State private var backdropOpacity: Double = 0

    @State private var bubbleOpacity: Double = 0
    @State private var bubbleScale: CGFloat = 0.9
    @State private var bubbleOffsetY: CGFloat = 12
    @State private var idleBubbleScale: CGFloat = 1.0

    var body: some View {
        SceneStage(emotion: .tired, duration: sceneDuration, onComplete: onComplete) {
            ZStack {
                TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { context in
                    let t = max(0, context.date.timeIntervalSince(epoch))
                    tiredLayeredScene(t: t)
                        .opacity(backdropOpacity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                LinearGradient(
                    colors: [.black.opacity(0.22), .clear],
                    startPoint: .top,
                    endPoint: .center
                )
                .ignoresSafeArea()
                .allowsHitTesting(false)
                .opacity(backdropOpacity)

                if let customText, !customText.isEmpty {
                    VStack {
                        CustomTextBadge(text: customText, tint: .white)
                            .padding(.top, 70)
                            .opacity(backdropOpacity)
                        Spacer()
                    }
                }

                VStack(spacing: 0) {
                    Spacer().frame(height: 52)

                    if behavior.showBubble {
                        ComfortSpeechBubble(text: message)
                            .opacity(bubbleOpacity)
                            .scaleEffect(bubbleScale * idleBubbleScale)
                            .offset(y: bubbleOffsetY)
                            .padding(.horizontal, 28)
                    }

                    Spacer()
                }
                .opacity(backdropOpacity)
            }
            .ignoresSafeArea()
            .onAppear {
                epoch = Date()
                runScene()
            }
        }
    }

    private func tiredLayeredScene(t: TimeInterval) -> some View {
        let active = t < motionDuration
        let phase = min(t / motionDuration, 1)
        let bgShift = active ? (-26 * phase) : -26
        let raftShiftX = active ? (28 * phase) : 28
        let bobY = active ? sin(t * .pi * 2 / 2.25) * 6 : 0

        let blinkPeriod: TimeInterval = 3.4
        let blinkT = t.truncatingRemainder(dividingBy: blinkPeriod)
        let eyesClosed = blinkT < 0.16

        return GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack(alignment: .bottom) {
                HealyBundleUIImageView(name: "sunset_ocean_background", contentMode: .scaleAspectFill)
                    .frame(width: w + 72, height: h)
                    .offset(x: bgShift)
                    .frame(width: w, height: h, alignment: .center)
                    .clipped()

                HealyBundleUIImageView(
                    name: eyesClosed ? "eyes_closed" : "healy_raft",
                    contentMode: .scaleAspectFit
                )
                .frame(width: w * 0.78, height: h * 0.44)
                .offset(x: raftShiftX, y: bobY)
                .padding(.bottom, h * 0.07)
            }
            .frame(width: w, height: h)
        }
    }

    private func runScene() {
        withAnimation(.easeOut(duration: 0.65)) {
            backdropOpacity = 1
        }

        if behavior.showBubble {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0 + behavior.bubbleDelayOffset) {
                withAnimation(.spring(response: 0.65, dampingFraction: 0.75)) {
                    bubbleOpacity = 1
                    bubbleScale = 1.0
                    bubbleOffsetY = 0
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + motionDuration) {
            withAnimation(.easeInOut(duration: 0.28)) {
                idleBubbleScale = 1.05
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                    idleBubbleScale = 1.0
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + sceneDuration - 1.5) {
            withAnimation(.easeIn(duration: 0.75)) {
                bubbleOpacity = 0
                bubbleOffsetY = 10
            }
        }
    }
}
