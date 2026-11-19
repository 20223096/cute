import SwiftUI

struct AnimationModeEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var customStore: CustomEmotionStore
    @EnvironmentObject private var journal: JournalStore

    @State private var activeRun: SceneRun?
    @State private var showCustomSheet: Bool = false
    @State private var showJournal: Bool = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.9, blue: 0.95), Color(red: 0.85, green: 0.92, blue: 1.0)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.primary.opacity(0.5))
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

                VStack(spacing: 10) {
                    Text("Animation Mode")
                        .font(.title2.weight(.bold))
                    Text("10초 동안 캐릭터와 잠깐 머물러요")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                ScrollView {
                    VStack(spacing: 14) {
                        customEntryCard

                        if !customStore.recent.isEmpty {
                            recentCustomStrip
                        }

                        ForEach(EmotionType.allCases) { emotion in
                            emotionCard(emotion)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .sheet(isPresented: $showCustomSheet) {
            CustomEmotionSheet { entry in
                triggerCustom(entry)
            }
            .environmentObject(appState)
            .environmentObject(customStore)
        }
        .sheet(isPresented: $showJournal) {
            JournalEntryView()
                .environmentObject(journal)
        }
        .fullScreenCover(item: $activeRun) { run in
            AnimationSceneView(
                emotion: run.reaction.emotion,
                character: run.reaction.character,
                message: run.reaction.message,
                mood: run.mood,
                customText: run.reaction.customText
            ) {
                appState.emotionLog.record(emotion: run.reaction.emotion, reaction: run.reaction)
                HealingEngine.store.saveReaction(run.reaction)
                activeRun = nil
            }
        }
    }

    private var customEntryCard: some View {
        Button {
            Haptics.play(.light)
            showCustomSheet = true
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "pencil.line")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(
                        LinearGradient(
                            colors: [Color.pink.opacity(0.85), Color.purple.opacity(0.65)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        in: Circle()
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("지금 마음, 한 줄 쓰기")
                        .font(.headline)
                    Text("내 말로 보내면 캐릭터가 닿아요")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.pink.opacity(0.9))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
            )
        }
        .buttonStyle(.plain)
    }

    private var recentCustomStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(customStore.recent.prefix(8)) { entry in
                    Button {
                        triggerCustom(entry)
                    } label: {
                        HStack(spacing: 6) {
                            Text(entry.mappedBase.emoji)
                            Text(entry.text)
                                .lineLimit(1)
                        }
                        .font(.footnote)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule().fill(.white.opacity(0.88))
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color.pink.opacity(0.18), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 2)
        }
    }

    private func emotionCard(_ emotion: EmotionType) -> some View {
        let anim = emotion.animation
        return Button {
            Haptics.play(.medium)
            if emotion == .talk {
                showJournal = true
                return
            }
            let variant = HealingEngine.variantSelector.select(for: emotion)
            let reaction = HealingEngine.reaction(using: variant)
            activeRun = SceneRun(reaction: reaction, mood: variant.mood)
        } label: {
            HStack(spacing: 18) {
                Text(emotion.emoji)
                    .font(.system(size: 44))
                    .frame(width: 70, height: 70)
                    .background(.white.opacity(0.9), in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(title(for: emotion))
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(subtitle(for: emotion))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: emotion == .talk ? "square.and.pencil" : "play.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.9))
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [anim.primaryColor.opacity(0.85), anim.secondaryColor.opacity(0.65)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 22, style: .continuous)
            )
            .shadow(color: anim.primaryColor.opacity(0.25), radius: 10, y: 4)
        }
        .buttonStyle(.plain)
    }

    private func triggerCustom(_ entry: CustomEmotion) {
        Haptics.play(.medium)
        let variant = HealingEngine.variantSelector.select(for: entry.mappedBase)
        let reaction = HealingEngine.reaction(using: variant, customText: entry.text)
        customStore.touch(entry)
        activeRun = SceneRun(reaction: reaction, mood: variant.mood)
    }

    private func title(for emotion: EmotionType) -> String {
        switch emotion {
        case .tired: return "힘들어"
        case .rest: return "쉬고 싶어"
        case .annoyed: return "짜증 나"
        case .numb: return "내가 쓸모없게 느껴져"
        case .worthless: return "자존감이 바닥이야"
        case .talk: return "얘기하고 싶어"
        }
    }

    private func subtitle(for emotion: EmotionType) -> String {
        switch emotion {
        case .tired: return "슬픔을 보자기에 싸서 뗏목에 실어 바다로 보내요"
        case .rest: return "귀마개·안대·커튼, 세상과 잠깐 차단"
        case .annoyed: return "샌드백을 직접 두드리며 비워내요"
        case .numb: return "선물이 쌓이고 머리에 리본이 묶여요"
        case .worthless: return "작은 꽃 한 송이와 함께 듣는 말"
        case .talk: return "감정 일기에 마음을 적어봐"
        }
    }
}

struct SceneRun: Identifiable {
    let id = UUID()
    let reaction: CompanionReaction
    let mood: VariantMood
}
