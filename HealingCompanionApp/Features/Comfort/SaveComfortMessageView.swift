import SwiftUI

struct SaveComfortMessageView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var comfortStore: ComfortMessageStore

    var onSaved: (ComfortToastPayload) -> Void = { _ in }

    @State private var text: String = ""
    @State private var overrideEmotion: EmotionType? = nil
    @State private var overrideMood: VariantMood? = nil
    @FocusState private var focused: Bool

    private let maxLen = 25

    private let suggestions: [String] = [
        "오늘도 잘 버텼어",
        "조금 쉬어도 괜찮아",
        "네 잘못 아니야",
        "내가 네 편이야",
        "천천히 해도 돼"
    ]

    private var trimmed: String { text.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var canSave: Bool { !trimmed.isEmpty }

    private var autoMapping: ComfortMapping? {
        guard !trimmed.isEmpty else { return nil }
        return ComfortMapper.map(trimmed)
    }

    private var effectiveEmotion: EmotionType {
        overrideEmotion ?? autoMapping?.emotion ?? .talk
    }
    private var effectiveMood: VariantMood {
        overrideMood ?? autoMapping?.mood ?? .quiet
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.97, blue: 0.95),
                        Color(red: 0.96, green: 0.95, blue: 1.0)
                    ],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        header
                        inputCard
                        if autoMapping != nil || overrideEmotion != nil {
                            mappingCard
                        }
                        suggestionBlock
                        if !comfortStore.messages.isEmpty {
                            savedListBlock
                        }
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") { dismiss() }
                        .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("담아두기") { save() }
                        .fontWeight(.semibold)
                        .foregroundStyle(canSave ? Color.pink : .secondary)
                        .disabled(!canSave)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { focused = true }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                Text("💌")
                    .font(.system(size: 28))
                Text("담아두고 싶은 한 마디")
                    .font(.title3.weight(.semibold))
            }
            Text("내가 듣고 싶은 말을 한 줄로 담아두면, 다음에 그 감정을 누를 때 들려줄게.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var inputCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text("예: 오늘도 잘 버텼어")
                        .font(.body)
                        .foregroundStyle(.secondary.opacity(0.6))
                        .padding(.top, 8)
                        .padding(.leading, 4)
                }
                TextEditor(text: $text)
                    .font(.body)
                    .scrollContentBackground(.hidden)
                    .focused($focused)
                    .frame(minHeight: 60, maxHeight: 100)
                    .onChange(of: text) { _, newValue in
                        if newValue.count > maxLen {
                            text = String(newValue.prefix(maxLen))
                        }
                    }
            }

            HStack {
                Spacer()
                Text("\(text.count)/\(maxLen)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    }

    private var mappingCard: some View {
        let emotion = effectiveEmotion
        let mood = effectiveMood
        let anim = emotion.animation

        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text("담길 감정")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                if overrideEmotion != nil || overrideMood != nil {
                    Button {
                        overrideEmotion = nil
                        overrideMood = nil
                    } label: {
                        Text("자동으로 되돌리기")
                            .font(.caption2)
                            .foregroundStyle(.blue.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack(spacing: 8) {
                Text(emotion.emoji)
                    .font(.system(size: 28))
                VStack(alignment: .leading, spacing: 2) {
                    Text(emotionLabel(emotion))
                        .font(.subheadline.weight(.semibold))
                    Text(mood.label)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                LinearGradient(
                    colors: [anim.primaryColor.opacity(0.45), anim.secondaryColor.opacity(0.3)],
                    startPoint: .leading, endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )

            emotionChipsRow
            moodChipsRow
        }
        .padding(14)
        .background(.white.opacity(0.78), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var emotionChipsRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("다른 감정으로 담기")
                .font(.caption2)
                .foregroundStyle(.secondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(EmotionType.allCases) { e in
                        Button {
                            overrideEmotion = (overrideEmotion == e) ? nil : e
                        } label: {
                            HStack(spacing: 4) {
                                Text(e.emoji)
                                Text(emotionLabel(e))
                                    .font(.caption)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                effectiveEmotion == e
                                ? AnyShapeStyle(e.animation.primaryColor.opacity(0.75))
                                : AnyShapeStyle(Color.white.opacity(0.7)),
                                in: Capsule()
                            )
                            .overlay(Capsule().stroke(Color.black.opacity(0.05)))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var moodChipsRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("톤")
                .font(.caption2)
                .foregroundStyle(.secondary)
            HStack(spacing: 8) {
                ForEach(VariantMood.allCases, id: \.self) { m in
                    Button {
                        overrideMood = (overrideMood == m) ? nil : m
                    } label: {
                        Text(m.label)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                effectiveMood == m
                                ? AnyShapeStyle(Color.pink.opacity(0.15))
                                : AnyShapeStyle(Color.white.opacity(0.7)),
                                in: Capsule()
                            )
                            .overlay(Capsule().stroke(effectiveMood == m ? Color.pink.opacity(0.45) : Color.black.opacity(0.05)))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var suggestionBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("이런 말들은 어때?")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(suggestions, id: \.self) { s in
                        Button {
                            text = s
                        } label: {
                            Text("“\(s)”")
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(.white.opacity(0.9), in: Capsule())
                                .overlay(Capsule().stroke(Color.black.opacity(0.05)))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var savedListBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Text("담아둔 말들")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text("\(comfortStore.messages.count)")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.black.opacity(0.4), in: Capsule())
                Spacer()
            }

            VStack(spacing: 8) {
                ForEach(comfortStore.messages) { entry in
                    savedRow(entry)
                }
            }
        }
    }

    private func savedRow(_ entry: SavedComfortMessage) -> some View {
        let anim = entry.emotion.animation
        return HStack(spacing: 10) {
            Button {
                Haptics.play(.light)
                text = entry.text
                overrideEmotion = entry.userOverridden ? entry.emotion : nil
                overrideMood = entry.userOverridden ? entry.mood : nil
            } label: {
                HStack(spacing: 10) {
                    Text(entry.emotion.emoji)
                        .font(.system(size: 18))
                        .frame(width: 34, height: 34)
                        .background(
                            LinearGradient(
                                colors: [anim.primaryColor.opacity(0.55), anim.secondaryColor.opacity(0.45)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            in: Circle()
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text("“\(entry.text)”")
                            .font(.subheadline)
                            .foregroundStyle(.primary.opacity(0.88))
                            .lineLimit(1)
                        HStack(spacing: 6) {
                            Text(entry.mood.label)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text("·")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(relativeDate(entry.createdAt))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer(minLength: 0)
                }
            }
            .buttonStyle(.plain)

            Button {
                Haptics.play(.light)
                comfortStore.delete(entry)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.body)
                    .foregroundStyle(.secondary.opacity(0.6))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.black.opacity(0.04))
        )
    }

    private func relativeDate(_ date: Date) -> String {
        let f = RelativeDateTimeFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.unitsStyle = .short
        return f.localizedString(for: date, relativeTo: Date())
    }

    private func save() {
        guard let entry = comfortStore.save(
            text: trimmed,
            overrideEmotion: overrideEmotion,
            overrideMood: overrideMood
        ) else { return }

        let payload = ComfortToastPayload(
            emotion: entry.emotion,
            mood: entry.mood,
            text: entry.text,
            caption: ComfortToastCopy.random()
        )
        onSaved(payload)
        dismiss()
    }

    private func emotionLabel(_ e: EmotionType) -> String {
        switch e {
        case .tired: return "지친 마음"
        case .rest: return "쉬고 싶은 마음"
        case .annoyed: return "짜증"
        case .numb: return "무감한 마음"
        case .worthless: return "작아진 마음"
        case .talk: return "털어놓는 마음"
        }
    }
}
