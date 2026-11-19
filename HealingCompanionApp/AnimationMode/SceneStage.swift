import SwiftUI

struct SceneStage<Content: View>: View {
    let emotion: EmotionType
    let duration: TimeInterval
    let onComplete: () -> Void
    @ViewBuilder let content: () -> Content

    @State private var progress: Double = 0
    @State private var remaining: TimeInterval
    @State private var sceneOpacity: Double = 0
    @State private var timerTask: Task<Void, Never>?

    init(
        emotion: EmotionType,
        duration: TimeInterval = 10,
        onComplete: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.emotion = emotion
        self.duration = duration
        self.onComplete = onComplete
        self.content = content
        self._remaining = State(initialValue: duration)
    }

    private var anim: EmotionAnimation { emotion.animation }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [anim.primaryColor.opacity(0.9), anim.secondaryColor.opacity(0.7)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(sceneOpacity)

            VStack {
                HStack {
                    Button { exitNow() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(6)
                    }
                    Spacer()
                    Text("\(Int(ceil(remaining)))s")
                        .font(.caption.monospacedDigit().weight(.medium))
                        .foregroundStyle(.white.opacity(0.85))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.black.opacity(0.18), in: Capsule())
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)

                Spacer()
                    .allowsHitTesting(false)

                ProgressView(value: progress)
                    .tint(.white.opacity(0.6))
                    .allowsHitTesting(false)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 24)
            }
        }
        .onAppear { start() }
        .onDisappear { timerTask?.cancel() }
    }

    private func start() {
        Haptics.play(anim.hapticStyle)
        withAnimation(.easeOut(duration: 0.45)) { sceneOpacity = 1 }

        let startDate = Date()
        timerTask?.cancel()
        timerTask = Task { @MainActor in
            while !Task.isCancelled {
                let elapsed = Date().timeIntervalSince(startDate)
                let p = min(elapsed / duration, 1.0)
                progress = p
                remaining = max(0, duration - elapsed)
                if p >= 1.0 {
                    exitWithFade()
                    return
                }
                try? await Task.sleep(nanoseconds: 50_000_000)
            }
        }
    }

    private func exitNow() {
        timerTask?.cancel()
        exitWithFade()
    }

    private func exitWithFade() {
        withAnimation(.easeIn(duration: 0.4)) { sceneOpacity = 0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.42) {
            onComplete()
        }
    }
}
