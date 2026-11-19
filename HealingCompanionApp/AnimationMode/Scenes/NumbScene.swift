import SwiftUI

/// 😶 "내가 쓸모없게 느껴져" — 배경 고정, 오른쪽 인물만 있다가 왼쪽 선물 등장 후 표정이 깜짝 → 웃음 → 리본으로 크로스페이드.
struct NumbScene: View {
    let character: CompanionCharacter
    let message: String
    var mood: VariantMood = .quiet
    var customText: String? = nil
    let onComplete: () -> Void

    private var behavior: SceneBehavior { SceneBehavior.from(mood) }

    private static let sceneComfortLine = "너는 존재 자체로 선물이야"

    private let charLayerCount = 4
    private var sceneDuration: TimeInterval { max(behavior.duration, 13) }

    @State private var epoch = Date()
    @State private var backdropOpacity: Double = 0

    @State private var bubbleOpacity: Double = 0
    @State private var bubbleScale: CGFloat = 0.92

    /// 일러스트가 왼쪽을 보면 `true`로 오른쪽을 보도록 뒤집기.
    private let numbCharMirrorHorizontal = true
    private func crossFade(_ d: TimeInterval) -> TimeInterval { min(0.62, max(0.38, d * 0.048)) }

    /// 선물 → 놀람 → 웃음 → 리본 순으로 각각 1초씩 늦춤 (누적 +1, +2, +3, +4초).
    private let beatStaggerSeconds: TimeInterval = 1.0
    private func beatDelay(step: Int) -> TimeInterval { TimeInterval(step) * beatStaggerSeconds }

    private func tCharInEnd(_ d: TimeInterval) -> TimeInterval { d * 0.12 }
    private func tGift(_ d: TimeInterval) -> TimeInterval { d * 0.22 + beatDelay(step: 1) }
    private func tToSurprised(_ d: TimeInterval) -> TimeInterval { d * 0.32 + beatDelay(step: 2) }
    private func tToSmile(_ d: TimeInterval) -> TimeInterval { d * 0.44 + beatDelay(step: 3) }
    private func tToRibbon(_ d: TimeInterval) -> TimeInterval { d * 0.56 + beatDelay(step: 4) }

    var body: some View {
        SceneStage(emotion: .numb, duration: sceneDuration, onComplete: onComplete) {
            ZStack {
                TimelineView(.animation(minimumInterval: 1.0 / 40.0)) { context in
                    let t = max(0, context.date.timeIntervalSince(epoch))
                    layeredScene(t: t)
                        .opacity(backdropOpacity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                if let customText, !customText.isEmpty {
                    VStack {
                        CustomTextBadge(text: customText, tint: .white)
                            .padding(.top, 70)
                            .opacity(backdropOpacity)
                        Spacer()
                    }
                }

                VStack(spacing: 0) {
                    Spacer().frame(height: 56)

                    if behavior.showBubble {
                        ComfortSpeechBubble(text: Self.sceneComfortLine, tailOffsetX: 0)
                            .opacity(bubbleOpacity)
                            .scaleEffect(bubbleScale)
                            .padding(.horizontal, 40)
                    }

                    Spacer()
                }
                .opacity(backdropOpacity)
            }
            .ignoresSafeArea()
            .onAppear {
                epoch = Date()
                runBeats()
            }
        }
    }

    private func layeredScene(t: TimeInterval) -> some View {
        let d = sceneDuration
        let cf = crossFade(d)
        let tIn = tCharInEnd(d)
        let tg = tGift(d)
        let s1 = tToSurprised(d)
        let s2 = tToSmile(d)
        let s3 = tToRibbon(d)

        return GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                HealyBundleUIImageView(name: "numb_bg_0", contentMode: .scaleAspectFill)
                    .frame(width: w, height: h)
                    .clipped()

                HealyBundleUIImageView(name: "numb_gift_0", contentMode: .scaleAspectFit)
                    .frame(width: w * 0.34, height: w * 0.34)
                    .offset(x: -w * 0.28, y: h * 0.14)
                    .opacity(giftOpacity(t: t, tGift: tg, cf: cf))

                ForEach(0..<charLayerCount, id: \.self) { i in
                    HealyBundleUIImageView(name: "numb_char_\(i)", contentMode: .scaleAspectFit)
                        .frame(width: w * 0.5, height: h * 0.42)
                        .scaleEffect(x: numbCharMirrorHorizontal ? -1 : 1, y: 1)
                        .offset(x: w * 0.1, y: h * 0.1)
                        .opacity(charOpacity(index: i, t: t, tInEnd: tIn, s1: s1, s2: s2, s3: s3, cf: cf))
                }
            }
            .frame(width: w, height: h)
        }
    }

    private func giftOpacity(t: TimeInterval, tGift: TimeInterval, cf: TimeInterval) -> CGFloat {
        if t < tGift { return 0 }
        if t < tGift + cf { return CGFloat((t - tGift) / cf) }
        return 1
    }

    private func charOpacity(
        index: Int,
        t: TimeInterval,
        tInEnd: TimeInterval,
        s1: TimeInterval,
        s2: TimeInterval,
        s3: TimeInterval,
        cf: TimeInterval
    ) -> CGFloat {
        let rampIn: CGFloat = {
            if t <= 0 { return 0 }
            if t >= tInEnd { return 1 }
            return CGFloat(t / tInEnd)
        }()

        let base: CGFloat = {
            switch index {
            case 0:
                if t < s1 { return 1 }
                if t < s1 + cf { return CGFloat(1 - (t - s1) / cf) }
                return 0
            case 1:
                if t < s1 { return 0 }
                if t < s1 + cf { return CGFloat((t - s1) / cf) }
                if t < s2 { return 1 }
                if t < s2 + cf { return CGFloat(1 - (t - s2) / cf) }
                return 0
            case 2:
                if t < s2 { return 0 }
                if t < s2 + cf { return CGFloat((t - s2) / cf) }
                if t < s3 { return 1 }
                if t < s3 + cf { return CGFloat(1 - (t - s3) / cf) }
                return 0
            case 3:
                if t < s3 { return 0 }
                if t < s3 + cf { return CGFloat((t - s3) / cf) }
                return 1
            default: return 0
            }
        }()

        return base * rampIn
    }

    private func runBeats() {
        withAnimation(.easeOut(duration: 0.85)) {
            backdropOpacity = 1
        }

        let d = sceneDuration
        let tg = tGift(d)
        let s1 = tToSurprised(d)

        DispatchQueue.main.asyncAfter(deadline: .now() + tg) {
            Haptics.play(.soft)
        }
        let s2 = tToSmile(d)
        let s3 = tToRibbon(d)
        DispatchQueue.main.asyncAfter(deadline: .now() + s1) {
            Haptics.play(.light)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + s2) {
            Haptics.play(.light)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + s3) {
            Haptics.play(.soft)
        }

        if behavior.showBubble {
            DispatchQueue.main.asyncAfter(deadline: .now() + min(1.35, d * 0.1) + behavior.bubbleDelayOffset) {
                withAnimation(.spring(response: 0.65, dampingFraction: 0.78)) {
                    bubbleOpacity = 1
                    bubbleScale = 1.0
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + sceneDuration - 1.25) {
            withAnimation(.easeIn(duration: 0.9)) {
                bubbleOpacity = 0
            }
        }
    }
}
