import SwiftUI

/// 😴 "쉬고 싶어" — 배경 3단계 + 캐릭터 3컷, 배경·캐릭터 전환 시점을 맞춰 크로스페이드.
///
/// - `rest_char_1` 컷이 끝난 뒤 → `rest_bg_0`에서 `rest_bg_1`(소등)으로.
/// - `rest_char_2` 컷이 끝난 뒤 → `rest_bg_1`에서 `rest_bg_2`(커튼)으로, 이때 캐릭터는 보이지 않게 페이드아웃.
struct RestScene: View {
    let character: CompanionCharacter
    let message: String
    var mood: VariantMood = .active
    var customText: String? = nil
    let onComplete: () -> Void

    private var behavior: SceneBehavior { SceneBehavior.from(mood) }

    private let bgCount = 3
    private let charCount = 3
    /// 배경 침대 방향에 맞춤: 필요 시에만 `true`(좌우 반전).
    private let restCharMirrorHorizontal = false
    /// 캐릭터 3컷 + 배경 전환 + 말풍선 여유
    private var sceneDuration: TimeInterval { max(behavior.duration, 14) }

    @State private var epoch = Date()
    @State private var backdropOpacity: Double = 0

    @State private var bubbleOpacity: Double = 0
    @State private var bubbleScale: CGFloat = 0.9
    @State private var bubbleOffsetY: CGFloat = 10

    /// 캐릭터 한 컷 구간(초). 3구간.
    private func charSegment(_ d: TimeInterval) -> TimeInterval { d * 0.22 }
    /// 배경 크로스페이드 길이 (캐릭터 최종 페이드아웃에도 동일 길이 사용)
    private func bgFade(_ d: TimeInterval) -> TimeInterval { min(0.72, max(0.48, d * 0.048)) }

    /// `rest_char_1` 다음(세 번째 컷 구간 시작)부터 밝은 방 → 소등.
    private func bg01Start(s: TimeInterval) -> TimeInterval { 2 * s }
    /// `rest_char_2` 다음(캐릭터 스토리 끝)부터 소등 → 커튼.
    private func bg12Start(s: TimeInterval) -> TimeInterval { s * Double(charCount) }

    var body: some View {
        SceneStage(emotion: .rest, duration: sceneDuration, onComplete: onComplete) {
            ZStack {
                TimelineView(.animation(minimumInterval: 1.0 / 45.0)) { context in
                    let t = max(0, context.date.timeIntervalSince(epoch))
                    layeredRestScene(t: t)
                        .opacity(backdropOpacity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                LinearGradient(
                    colors: [.black.opacity(0.18), .clear],
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
                        ComfortSpeechBubble(text: message, tailOffsetX: 0)
                            .opacity(bubbleOpacity)
                            .scaleEffect(bubbleScale)
                            .offset(y: bubbleOffsetY)
                            .padding(.horizontal, 36)
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

    private func layeredRestScene(t: TimeInterval) -> some View {
        let d = sceneDuration
        let s = charSegment(d)
        let bf = bgFade(d)
        let b01 = bg01Start(s: s)
        let b12 = bg12Start(s: s)
        let charEnd = b12

        return GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                ForEach(0..<bgCount, id: \.self) { i in
                    HealyBundleUIImageView(name: "rest_bg_\(i)", contentMode: .scaleAspectFill)
                        .frame(width: w, height: h)
                        .clipped()
                        .opacity(bgOpacity(index: i, t: t, b01: b01, b12: b12, bf: bf))
                }

                ForEach(0..<charCount, id: \.self) { i in
                    HealyBundleUIImageView(name: "rest_char_\(i)", contentMode: .scaleAspectFit)
                        .frame(width: w * 0.92, height: h * 0.55)
                        .scaleEffect(x: restCharMirrorHorizontal ? -1 : 1, y: 1)
                        .offset(y: h * 0.06)
                        .opacity(charOpacity(index: i, t: t, seg: s, charEnd: charEnd, bf: bf))
                }
            }
            .frame(width: w, height: h)
        }
    }

    // MARK: - 배경 (0: 밝음, 1: 소등, 2: 커튼)

    private func bgOpacity(index: Int, t: TimeInterval, b01: TimeInterval, b12: TimeInterval, bf: TimeInterval) -> CGFloat {
        let o0 = bg0Channel(t: t, b01: b01, bf: bf)
        let o1 = bg1Channel(t: t, b01: b01, b12: b12, bf: bf)
        let o2 = bg2Channel(t: t, b12: b12, bf: bf)
        switch index {
        case 0: return o0
        case 1: return o1
        case 2: return o2
        default: return 0
        }
    }

    private func bg0Channel(t: TimeInterval, b01: TimeInterval, bf: TimeInterval) -> CGFloat {
        if t <= b01 { return 1 }
        if t >= b01 + bf { return 0 }
        return CGFloat(1 - (t - b01) / bf)
    }

    private func bg1Channel(t: TimeInterval, b01: TimeInterval, b12: TimeInterval, bf: TimeInterval) -> CGFloat {
        if t <= b01 { return 0 }
        if t < b01 + bf { return CGFloat((t - b01) / bf) }
        if t <= b12 { return 1 }
        if t < b12 + bf { return CGFloat(1 - (t - b12) / bf) }
        return 0
    }

    private func bg2Channel(t: TimeInterval, b12: TimeInterval, bf: TimeInterval) -> CGFloat {
        if t <= b12 { return 0 }
        if t < b12 + bf { return CGFloat((t - b12) / bf) }
        return 1
    }

    // MARK: - 캐릭터 (3컷 + 커튼 전 구간에서 페이드아웃)

    private func charOpacity(index: Int, t: TimeInterval, seg: TimeInterval, charEnd: TimeInterval, bf: TimeInterval) -> CGFloat {
        let fadePortion: CGFloat = 0.34
        /// `rest_char_2` 직후 ~ 커튼 페이드와 같은 구간에 캐릭터 전체를 서서히 제거
        let charMaster: CGFloat = {
            if t < charEnd { return 1 }
            if t >= charEnd + bf { return 0 }
            return CGFloat(1 - (t - charEnd) / bf)
        }()

        if charMaster == 0 { return 0 }

        if t >= charEnd {
            return index == charCount - 1 ? charMaster : 0
        }

        let fi = min(t / seg, Double(charCount) - 0.000001)
        let idx = Int(floor(fi))
        let frac = CGFloat(fi - Double(idx))
        let blend: CGFloat = {
            if idx >= charCount - 1 { return 0 }
            return min(1, max(0, (frac - (1 - fadePortion)) / fadePortion))
        }()
        let inner: CGFloat = {
            if index == idx { return 1 - blend }
            if index == idx + 1 { return blend }
            return 0
        }()
        return inner * charMaster
    }

    private func runScene() {
        withAnimation(.easeOut(duration: 0.7)) {
            backdropOpacity = 1
        }

        if behavior.showBubble {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0 + behavior.bubbleDelayOffset) {
                withAnimation(.spring(response: 0.68, dampingFraction: 0.78)) {
                    bubbleOpacity = 1
                    bubbleScale = 1.0
                    bubbleOffsetY = 0
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + sceneDuration - 1.35) {
            withAnimation(.easeIn(duration: 0.85)) {
                bubbleOpacity = 0
                bubbleOffsetY = 8
            }
        }
    }
}
