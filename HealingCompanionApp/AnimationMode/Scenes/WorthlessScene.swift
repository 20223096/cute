import SwiftUI

/// 자존감 장면: **밤 배경 고정** + 화면 **가운데 땅 위**에서 `worthless_flower_0…5`가 **2→3→4→5→6→7** 단계(에셋 0…5)로 피어 오름.
struct WorthlessScene: View {
    let character: CompanionCharacter
    let message: String
    var mood: VariantMood = .active
    var customText: String? = nil
    let onComplete: () -> Void

    private var behavior: SceneBehavior { SceneBehavior.from(mood) }

    @State private var backdropOpacity: Double = 0
    @State private var glowOpacity: Double = 0
    @State private var glowScale: CGFloat = 0.4

    @State private var flowerStage: Int = 0
    @State private var flowerContainerOffsetY: CGFloat = 14
    @State private var flowerContainerOpacity: Double = 0

    @State private var showSparkles: Bool = false
    @State private var sparkleOpacity: Double = 0

    @State private var bubbleOpacity: Double = 0
    @State private var bubbleScale: CGFloat = 0.88
    @State private var bubbleOffsetY: CGFloat = 14

    @State private var petalFall = false

    private static let bgName = "worthless_night_bg"
    private static let flowerPrefix = "worthless_flower"
    private static let flowerFrameCount = 6
    /// 이미지 2~7 단계(0…5 인덱스) 사이 시간 간격(초)
    private static let bloomStepInterval: TimeInterval = 0.86
    /// 화면(배경) 맨 아래에서 화분 영역을 띄우는 거리
    private static let potInsetFromBottom: CGFloat = 30

    var body: some View {
        SceneStage(emotion: .worthless, duration: behavior.duration, onComplete: onComplete) {
            ZStack(alignment: .bottom) {
                HealyBundleUIImageView(name: Self.bgName, contentMode: .scaleAspectFill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .ignoresSafeArea(edges: [.horizontal, .bottom, .top])
                    .opacity(backdropOpacity)

                GeometryReader { geo in
                    let w = geo.size.width
                    let h = geo.size.height
                    ZStack {
                        fallingPetals
                        warmGlow
                            .position(x: w / 2, y: h * 0.55)
                            .opacity(glowOpacity)
                            .scaleEffect(glowScale)

                        if showSparkles {
                            SoftSparkleView(count: 10, tint: .white)
                                .frame(width: 280, height: 280)
                                .position(x: w / 2, y: h * 0.52)
                                .opacity(sparkleOpacity)
                        }
                    }
                    .frame(width: w, height: h)
                }
                .ignoresSafeArea()
                .allowsHitTesting(false)

                if let customText, !customText.isEmpty {
                    VStack {
                        CustomTextBadge(text: customText, tint: .black)
                            .padding(.top, 70)
                            .opacity(backdropOpacity)
                        Spacer()
                    }
                }

                GeometryReader { geo in
                    let w = geo.size.width
                    let h = geo.size.height
                    VStack(spacing: 10) {
                        Spacer(minLength: 0)

                        if behavior.showBubble {
                            ComfortSpeechBubble(text: message)
                                .opacity(bubbleOpacity)
                                .scaleEffect(bubbleScale)
                                .offset(y: bubbleOffsetY)
                                .padding(.horizontal, 32)
                        }

                        ZStack {
                            ForEach(0..<Self.flowerFrameCount, id: \.self) { i in
                                HealyBundleUIImageView(
                                    name: "\(Self.flowerPrefix)_\(i)",
                                    contentMode: .scaleAspectFit
                                )
                                .frame(width: w * 0.58, height: h * 0.36)
                                .opacity(flowerStage == i ? 1 : 0)
                            }
                        }
                        .offset(y: flowerContainerOffsetY)
                        .opacity(flowerContainerOpacity * backdropOpacity)
                        .accessibilityLabel("꽃이 한 단계씩 피어 납니다")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding(.bottom, Self.potInsetFromBottom)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear { runScene() }
        }
    }

    private var warmGlow: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Color(red: 1.0, green: 0.92, blue: 0.68).opacity(0.85),
                        Color(red: 0.9, green: 0.95, blue: 0.78).opacity(0.0)
                    ],
                    center: .center,
                    startRadius: 20,
                    endRadius: 280
                )
            )
            .frame(width: 440, height: 440)
            .blendMode(.plusLighter)
            .allowsHitTesting(false)
    }

    private var fallingPetals: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<8, id: \.self) { i in
                    Circle()
                        .fill(Color(red: 1.0, green: 0.78, blue: 0.88).opacity(0.75))
                        .frame(width: 10, height: 8)
                        .offset(
                            x: petalFall
                                ? CGFloat((i * 7 + 13) % 17) * 0.12 * geo.size.width - geo.size.width * 0.4
                                : CGFloat(i) * 40 - geo.size.width / 2,
                            y: petalFall ? geo.size.height / 2 + 30 : -geo.size.height / 2 - 20
                        )
                        .rotationEffect(.degrees(petalFall ? 180 : 0))
                        .animation(
                            .linear(duration: Double(7 + (i % 4)) * 0.15 + 6.2)
                                .repeatForever(autoreverses: false)
                                .delay(Double(i) * 0.6),
                            value: petalFall
                        )
                        .opacity(flowerContainerOpacity * 0.9)
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func runScene() {
        withAnimation(.easeOut(duration: 0.7)) {
            backdropOpacity = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            petalFall = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeInOut(duration: 2.0)) {
                glowOpacity = 1
                glowScale = 1.0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.82)) {
                flowerContainerOffsetY = 0
                flowerContainerOpacity = 1.0
            }
        }

        for step in 1..<Self.flowerFrameCount {
            let delay = 0.42 + Double(step - 1) * Self.bloomStepInterval
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: 0.58)) {
                    flowerStage = step
                }
                Haptics.play(.soft)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
            Haptics.play(.soft)
            withAnimation(.easeOut(duration: 0.6)) {
                showSparkles = true
                sparkleOpacity = 1.0
            }
        }

        if behavior.showBubble {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0 + behavior.bubbleDelayOffset) {
                withAnimation(.spring(response: 0.65, dampingFraction: 0.75)) {
                    bubbleOpacity = 1.0
                    bubbleScale = 1.0
                    bubbleOffsetY = 0
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + behavior.duration - 1.7) {
            withAnimation(.easeIn(duration: 0.9)) {
                bubbleOpacity = 0
                bubbleOffsetY = 10
            }
            withAnimation(.easeIn(duration: 1.2)) {
                sparkleOpacity = 0
            }
        }
    }
}
