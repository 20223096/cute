import SwiftUI

struct LetterComposeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var letterStore: LetterStore
    @EnvironmentObject private var comfortStore: ComfortMessageStore

    @State private var selectedFriend: Friend?
    @State private var selectedEmotion: EmotionType?
    @State private var selectedMood: VariantMood?
    @State private var customText: String = ""
    @State private var isSending = false
    @State private var sendFloat = false
    @FocusState private var textFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                background
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        header
                        friendSection
                        emotionSection
                        if let _ = selectedEmotion {
                            moodSection
                            messageSection
                            previewCard
                        }
                        Spacer(minLength: 80)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 30)
                }

                sendOverlay
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") { dismiss() }
                        .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { attemptSend() } label: {
                        Text("보내기")
                            .fontWeight(.semibold)
                    }
                    .disabled(!canSend)
                    .foregroundStyle(canSend ? Color.pink : .secondary)
                }
            }
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.96, blue: 0.95),
                Color(red: 0.95, green: 0.96, blue: 1.0)
            ],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text("✉️")
                    .font(.system(size: 26))
                Text("편지 쓰기")
                    .font(.title3.weight(.semibold))
            }
            Text("작은 감정 하나, 친구에게 조용히 건네보자.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var friendSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("누구에게")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(appState.friendsStore.friends) { friend in
                        friendChip(friend)
                    }
                }
            }
        }
    }

    private func friendChip(_ friend: Friend) -> some View {
        let selected = selectedFriend?.id == friend.id
        return Button {
            selectedFriend = friend
            Haptics.play(.light)
        } label: {
            VStack(spacing: 6) {
                HealyAvatarView(emotion: friend.recentEntries.first?.emotion ?? .talk, size: 40)
                    .frame(width: 54, height: 54)
                    .background(.white.opacity(selected ? 1 : 0.85), in: Circle())
                    .overlay(
                        Circle()
                            .stroke(selected ? Color.pink.opacity(0.7) : Color.clear, lineWidth: 2)
                    )
                Text(friend.name)
                    .font(.caption)
                    .foregroundStyle(.primary.opacity(0.85))
            }
        }
        .buttonStyle(.plain)
    }

    private var emotionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("어떤 마음을 담을래")
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                ForEach(EmotionType.allCases) { e in
                    emotionTile(e)
                }
            }
        }
    }

    private func emotionTile(_ e: EmotionType) -> some View {
        let selected = selectedEmotion == e
        let anim = e.animation
        return Button {
            Haptics.play(.soft)
            selectedEmotion = e
            selectedMood = nil
        } label: {
            VStack(spacing: 4) {
                Text(e.emoji)
                    .font(.system(size: 34))
                Text(emotionLabel(e))
                    .font(.caption)
                    .foregroundStyle(.primary.opacity(0.85))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [
                        anim.primaryColor.opacity(selected ? 0.85 : 0.35),
                        anim.secondaryColor.opacity(selected ? 0.65 : 0.22)
                    ],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(selected ? Color.pink.opacity(0.6) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private var moodSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("어떤 톤으로")
            let moods = EmotionVariantCatalog.variants(for: selectedEmotion!).map(\.mood)
            var seen = Set<VariantMood>()
            let uniqueMoods = moods.filter { seen.insert($0).inserted }
            HStack(spacing: 8) {
                ForEach(uniqueMoods, id: \.self) { m in
                    moodChip(m)
                }
            }
        }
    }

    private func moodChip(_ mood: VariantMood) -> some View {
        let selected = selectedMood == mood
        return Button {
            Haptics.play(.light)
            selectedMood = mood
        } label: {
            Text(mood.label)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    selected
                    ? AnyShapeStyle(Color.pink.opacity(0.85))
                    : AnyShapeStyle(Color.white.opacity(0.85)),
                    in: Capsule()
                )
                .foregroundStyle(selected ? .white : .primary.opacity(0.85))
                .overlay(Capsule().stroke(Color.black.opacity(0.05)))
        }
        .buttonStyle(.plain)
    }

    private var messageSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("어떤 말을 전할래")

            VStack(alignment: .leading, spacing: 8) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(suggestedMessages, id: \.self) { msg in
                            suggestionChip(msg, highlighted: isSaved(msg))
                        }
                    }
                }

                ZStack(alignment: .topLeading) {
                    if customText.isEmpty {
                        Text("직접 쓰기 (25자 이내)")
                            .font(.body)
                            .foregroundStyle(.secondary.opacity(0.6))
                            .padding(.top, 8)
                            .padding(.leading, 4)
                    }
                    TextEditor(text: $customText)
                        .font(.body)
                        .scrollContentBackground(.hidden)
                        .focused($textFocused)
                        .frame(minHeight: 60, maxHeight: 80)
                        .onChange(of: customText) { _, newValue in
                            if newValue.count > 25 {
                                customText = String(newValue.prefix(25))
                            }
                        }
                }
                .padding(12)
                .background(.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }

    private func suggestionChip(_ msg: String, highlighted: Bool) -> some View {
        Button {
            customText = msg
            textFocused = false
            Haptics.play(.light)
        } label: {
            HStack(spacing: 4) {
                if highlighted { Text("💌").font(.caption2) }
                Text("“\(msg)”")
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                highlighted ? AnyShapeStyle(Color.pink.opacity(0.15)) : AnyShapeStyle(Color.white.opacity(0.85)),
                in: Capsule()
            )
            .overlay(
                Capsule().stroke(highlighted ? Color.pink.opacity(0.4) : Color.black.opacity(0.05))
            )
        }
        .buttonStyle(.plain)
    }

    private var previewCard: some View {
        let emotion = selectedEmotion ?? .talk
        let anim = emotion.animation
        let mood = selectedMood ?? .quiet
        return VStack(spacing: 10) {
            Text("미리보기")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 14) {
                EnvelopeView(
                    primaryColor: anim.primaryColor.opacity(0.9),
                    secondaryColor: anim.secondaryColor.opacity(0.95),
                    sealSymbol: nil,
                    sealEmotion: emotion,
                    size: CGSize(width: 100, height: 72)
                )
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedFriend?.name ?? "친구")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.primary.opacity(0.8))
                    Text("“\(customText.isEmpty ? "여기 있어" : customText)”")
                        .font(.subheadline)
                        .foregroundStyle(.primary.opacity(0.9))
                        .lineLimit(2)
                    Text("\(emotion.emoji) · \(mood.label)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(12)
            .background(
                LinearGradient(
                    colors: [Color.white.opacity(0.95), anim.primaryColor.opacity(0.35)],
                    startPoint: .leading, endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: 22, style: .continuous)
            )
        }
        .padding(.top, 4)
    }

    private var sendOverlay: some View {
        ZStack {
            if isSending {
                Color.black.opacity(0.25).ignoresSafeArea()
                EnvelopeView(
                    primaryColor: (selectedEmotion ?? .talk).animation.primaryColor,
                    secondaryColor: (selectedEmotion ?? .talk).animation.secondaryColor,
                    sealSymbol: nil,
                    sealEmotion: selectedEmotion ?? .talk,
                    size: CGSize(width: 200, height: 140)
                )
                .scaleEffect(sendFloat ? 0.3 : 1.0)
                .offset(y: sendFloat ? -600 : 0)
                .opacity(sendFloat ? 0 : 1)
                .animation(.easeIn(duration: 0.9), value: sendFloat)
            }
        }
    }

    private var canSend: Bool {
        selectedFriend != nil
        && selectedEmotion != nil
        && !customText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func attemptSend() {
        guard let friend = selectedFriend,
              let emotion = selectedEmotion else { return }
        let mood = selectedMood ?? EmotionVariantCatalog.variants(for: emotion).first?.mood ?? .quiet
        let variant = EmotionVariantCatalog.variants(for: emotion).first(where: { $0.mood == mood })
        let trimmed = customText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        letterStore.send(
            to: friend,
            emotion: emotion,
            mood: mood,
            variantID: variant?.id,
            message: trimmed
        )

        Haptics.play(.medium)
        isSending = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            sendFloat = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            dismiss()
        }
    }

    private var suggestedMessages: [String] {
        guard let emotion = selectedEmotion else { return [] }
        let mood = selectedMood
        let variant = mood.flatMap { m in EmotionVariantCatalog.variants(for: emotion).first(where: { $0.mood == m }) }
            ?? EmotionVariantCatalog.variants(for: emotion).first

        let presets = variant?.messages ?? HealingCatalog.responses[emotion] ?? []
        let saved = comfortStore.messages(for: emotion, mood: mood).map(\.text)

        var combined = saved + presets.filter { !saved.contains($0) }
        if combined.count > 8 { combined = Array(combined.prefix(8)) }
        return combined
    }

    private func isSaved(_ text: String) -> Bool {
        comfortStore.messages.contains { $0.text == text }
    }

    private func sectionTitle(_ s: String) -> some View {
        Text(s)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
    }

    private func emotionLabel(_ e: EmotionType) -> String {
        switch e {
        case .tired: return "지친 마음"
        case .rest: return "쉼"
        case .annoyed: return "짜증"
        case .numb: return "무감"
        case .worthless: return "작아짐"
        case .talk: return "이야기"
        }
    }
}
