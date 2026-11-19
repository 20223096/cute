import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var journal: JournalStore
    @EnvironmentObject private var emotionLog: EmotionLog
    @EnvironmentObject private var comfortStore: ComfortMessageStore

    @State private var pulseEmotion: EmotionType?
    @State private var particlesKey = UUID()
    @State private var wanderOffset: CGSize = .zero
    @State private var showAnimationMode = false
    @State private var showJournal = false
    @State private var showTodaySummary = false
    @State private var showSaveComfort = false
    @State private var toastPayload: ComfortToastPayload?

    private var reaction: CompanionReaction { appState.currentReaction }
    private var anim: EmotionAnimation { reaction.emotion.animation }

    /// The "오늘의 정리" card only appears at the end of the day (after 23:00)
    /// so it feels like a real day-closing wrap-up instead of a live ticker.
    private static let summaryUnlockHour: Int = 23
    private var todaySummary: DaySummary? {
        let hour = Calendar.current.component(.hour, from: Date())
        guard hour >= Self.summaryUnlockHour else { return nil }
        return emotionLog.todaySummary
    }

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.6), value: reaction.emotion)

            ParticleEmitter(style: anim.particleStyle)
                .id(particlesKey)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                if let summary = todaySummary {
                    todaySummaryCard(summary)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                } else {
                    Spacer(minLength: 20)
                }

                Text(reaction.character.name)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary.opacity(0.8))
                    .transition(.opacity)

                CharacterView(
                    reaction: reaction,
                    motion: anim.motion,
                    size: 98
                )
                .id("char-\(reaction.id)")
                .offset(wanderOffset)
                .frame(height: 150)
                .animation(.easeInOut(duration: 2.6), value: wanderOffset)
                .task { startWandering() }

                Text(reaction.message)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
                    .padding(.horizontal, 28)
                    .id("msg-\(reaction.id)")
                    .transition(.scale(scale: 0.85).combined(with: .opacity))

                Spacer()

                emojiRow

                VStack(spacing: 10) {
                    saveComfortButton
                    animationModeButton
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 20)
            }
        }
        .comfortToast($toastPayload)
        .fullScreenCover(isPresented: $showAnimationMode) {
            AnimationModeEntryView()
        }
        .sheet(isPresented: $showJournal) {
            JournalEntryView()
                .environmentObject(journal)
        }
        .sheet(isPresented: $showTodaySummary) {
            if let summary = todaySummary {
                EmotionDayDetailView(summary: summary)
            }
        }
        .sheet(isPresented: $showSaveComfort) {
            SaveComfortMessageView { payload in
                toastPayload = payload
            }
            .environmentObject(comfortStore)
        }
        .onChange(of: appState.pendingJournalRequest) { _, newValue in
            if newValue {
                showJournal = true
                appState.clearJournalRequest()
            }
        }
        .onAppear {
            if appState.pendingJournalRequest {
                showJournal = true
                appState.clearJournalRequest()
            }
        }
    }

    private func todaySummaryCard(_ summary: DaySummary) -> some View {
        let emojis = summary.emotionsInOrder.prefix(5).map(\.emoji).joined(separator: "  ")
        let dominant = summary.dominantEmotion ?? summary.moments.first?.emotion ?? .numb
        let animTint = dominant.animation
        return Button {
            Haptics.play(.light)
            showTodaySummary = true
        } label: {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("오늘의 정리")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.primary.opacity(0.55))
                    Text(emojis)
                        .font(.title3)
                }
                Spacer(minLength: 6)
                HStack(spacing: 4) {
                    Text("\(summary.count)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.black.opacity(0.4), in: Capsule())
                    Image(systemName: "chevron.right")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.primary.opacity(0.45))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [.white.opacity(0.9), animTint.primaryColor.opacity(0.25)],
                    startPoint: .leading, endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
            .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
        }
        .buttonStyle(.plain)
    }

    private var emojiRow: some View {
        HStack(spacing: 12) {
            ForEach(EmotionType.allCases) { emotion in
                Button {
                    handleTap(emotion: emotion)
                } label: {
                    Text(emotion.emoji)
                        .font(.system(size: 28))
                        .frame(width: 50, height: 50)
                        .background(.white.opacity(0.8), in: Circle())
                        .scaleEffect(pulseEmotion == emotion ? 1.3 : 1.0)
                        .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
                        .animation(.spring(response: 0.25, dampingFraction: 0.4), value: pulseEmotion)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var saveComfortButton: some View {
        Button {
            Haptics.play(.light)
            showSaveComfort = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "heart.text.square.fill")
                Text("담아두고 싶은 한 마디")
                    .fontWeight(.semibold)
                Spacer()
                Text("💌")
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(.white.opacity(0.88), in: Capsule())
            .foregroundStyle(Color(red: 0.45, green: 0.28, blue: 0.45))
            .overlay(Capsule().stroke(Color.pink.opacity(0.25)))
        }
        .buttonStyle(.plain)
    }

    private var animationModeButton: some View {
        Button {
            Haptics.play(.medium)
            showAnimationMode = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                Text("Animation Mode")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [Color.pink.opacity(0.85), Color.purple.opacity(0.7)],
                    startPoint: .leading, endPoint: .trailing
                ),
                in: Capsule()
            )
            .foregroundStyle(.white)
            .shadow(color: .pink.opacity(0.3), radius: 8, y: 3)
        }
        .buttonStyle(.plain)
    }

    private func handleTap(emotion: EmotionType) {
        pulseEmotion = emotion
        Haptics.play(emotion.animation.hapticStyle)

        if emotion == .talk {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                pulseEmotion = nil
                showJournal = true
            }
            return
        }

        withAnimation(.spring(response: 0.45, dampingFraction: 0.55)) {
            _ = appState.triggerReaction(for: emotion)
        }
        particlesKey = UUID()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            pulseEmotion = nil
        }
    }

    private func startWandering() {
        Task { @MainActor in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 2_800_000_000)
                wanderOffset = CGSize(
                    width: CGFloat.random(in: -40...40),
                    height: CGFloat.random(in: -18...18)
                )
            }
        }
    }

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [anim.primaryColor.opacity(0.75), anim.secondaryColor.opacity(0.55)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
