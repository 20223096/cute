import SwiftUI

/// 짜증 씬: **고정 체육관 배경** + **1→2→3 캐릭터 프레임** + 터치/탭으로 **샌드백 흔들림** (illustration 위 샌드백 영역, 상단 흔들림 앵커)
struct AnnoyedScene: View {
    let character: CompanionCharacter
    let message: String
    var mood: VariantMood = .active
    var customText: String? = nil
    let onComplete: () -> Void

    private var behavior: SceneBehavior { SceneBehavior.from(mood) }
    private var sceneDuration: TimeInterval { behavior.duration + 4.5 }

    @State private var backdropOpacity: Double = 0
    @State private var illustrationOpacity: Double = 0
    @State private var illustrationOffsetY: CGFloat = 36
    @State private var punchFrame: Int = 0

    @State private var bagShakeX: CGFloat = 0
    @State private var bagShakeRot: Double = 0

    @State private var flashOpacity: Double = 0
    @State private var showBurst = false
    @State private var burstKey = UUID()

    @State private var bubbleOpacity: Double = 0
    @State private var bubbleScale: CGFloat = 0.9

    @State private var lastUserPunch: Date = .distantPast
    @State private var isPunchSequenceActive = false

    private let autoPunches = 2

    /// illust 내 **왼쪽 샌드백** 상단 고리 근처 (흔들림 기준)
    private let bagSwingAnchor = UnitPoint(x: 0.3, y: 0.04)
    private let charAssetPrefix = "annoyed_char"
    private let bgName = "annoyed_gym_bg"

    var body: some View {
        SceneStage(emotion: .annoyed, duration: sceneDuration, onComplete: onComplete) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height

                ZStack {
                    Color.white.opacity(flashOpacity)
                        .ignoresSafeArea()

                    HealyBundleUIImageView(name: bgName, contentMode: .scaleAspectFill)
                        .frame(width: w, height: h)
                        .clipped()
                        .opacity(backdropOpacity)

                    if showBurst {
                        ParticleEmitter(style: .sharpBurst)
                            .id(burstKey)
                            .transition(.opacity)
                    }

                    if let customText, !customText.isEmpty {
                        VStack {
                            CustomTextBadge(text: customText)
                                .padding(.top, 70)
                                .opacity(backdropOpacity)
                            Spacer()
                        }
                    }

                    VStack(spacing: 20) {
                        Spacer()

                        if behavior.showBubble {
                            ComfortSpeechBubble(text: message, tailOffsetX: 0)
                                .opacity(bubbleOpacity)
                                .scaleEffect(bubbleScale)
                                .padding(.horizontal, 36)
                        }

                        ZStack(alignment: .center) {
                            ForEach(0..<3, id: \.self) { i in
                                HealyBundleUIImageView(
                                    name: "\(charAssetPrefix)_\(i)",
                                    contentMode: .scaleAspectFit
                                )
                                .frame(width: w * 0.98, height: h * 0.44)
                                .opacity(punchFrame == i ? 1 : 0)
                            }
                        }
                        .offset(x: bagShakeX, y: illustrationOffsetY)
                        .rotationEffect(.degrees(bagShakeRot), anchor: bagSwingAnchor)
                        .opacity(illustrationOpacity * backdropOpacity)
                        .contentShape(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                        )
                        .onTapGesture { userPunchBag() }
                        .accessibilityAddTraits(.isButton)
                        .accessibilityLabel("샌드백 때리기")
                        .padding(.bottom, 4)

                        Spacer().frame(height: 60)
                    }
                }
            }
            .onAppear { runScene() }
        }
    }

    private func runScene() {
        withAnimation(.easeOut(duration: 0.6)) {
            backdropOpacity = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.85, dampingFraction: 0.82)) {
                illustrationOffsetY = 0
                illustrationOpacity = 1
            }
        }

        for i in 0..<autoPunches {
            let t = 1.3 + Double(i) * 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + t) {
                hitBag(fromUser: false)
            }
        }

        if behavior.showBubble {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3 + Double(autoPunches) * 1.0 + 0.4 + behavior.bubbleDelayOffset) {
                withAnimation(.spring(response: 0.7, dampingFraction: 0.75)) {
                    bubbleOpacity = 1
                    bubbleScale = 1.0
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + sceneDuration - 1.5) {
            withAnimation(.easeIn(duration: 1.0)) {
                bubbleOpacity = 0
            }
        }
    }

    private func userPunchBag() {
        let now = Date()
        guard now.timeIntervalSince(lastUserPunch) > 0.2 else { return }
        lastUserPunch = now
        hitBag(fromUser: true)
    }

    private func hitBag(fromUser: Bool) {
        guard !isPunchSequenceActive else { return }
        isPunchSequenceActive = true
        Haptics.playPunchImpact(userDriven: fromUser)
        if fromUser { Haptics.playPunchTock() }

        let flashLevel: Double = fromUser ? 0.16 : 0.24
        flashOpacity = flashLevel
        withAnimation(.easeOut(duration: 0.32)) {
            flashOpacity = 0
        }

        burstKey = UUID()
        showBurst = true

        runPunchFrameSequence {
            isPunchSequenceActive = false
            withAnimation(.spring(response: 0.22, dampingFraction: 0.6)) {
                bagShakeX = 0
                bagShakeRot = 0
            }
            showBurst = false
        }

        withAnimation(.spring(response: 0.16, dampingFraction: 0.36)) {
            bagShakeX = fromUser ? 20 : 16
            bagShakeRot = fromUser ? 10 : 8.5
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.spring(response: 0.36, dampingFraction: 0.4)) {
                bagShakeX = -7
                bagShakeRot = -3.5
            }
        }
    }

    /// 1 → 2 → 3(타격) → 1(대기 = frame 0)
    private func runPunchFrameSequence(onComplete: @escaping () -> Void) {
        withAnimation(.easeOut(duration: 0.055)) { punchFrame = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.easeOut(duration: 0.05)) { punchFrame = 2 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeOut(duration: 0.07)) { punchFrame = 0 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onComplete()
        }
    }
}
