import SwiftUI

struct JournalEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var journal: JournalStore

    var editing: JournalEntry?

    @State private var text: String = ""
    @State private var mood: EmotionType? = nil
    @State private var showList: Bool = false
    @FocusState private var focused: Bool

    private let maxLen = 600

    private var isEditing: Bool { editing != nil }
    private var canSave: Bool { !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    private let prompts: [String] = [
        "너의 이야기를 들려줘",
        "오늘, 어떤 하루였어?",
        "지금 떠오르는 말, 그대로 적어봐",
        "나는 다 들을 준비가 되어 있어"
    ]

    @State private var chosenPrompt: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                paperBackground

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        header

                        notebookCard

                        moodChips

                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 12)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("닫기") { dismiss() }
                        .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .principal) {
                    Text(dateLabel)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 14) {
                        Button {
                            showList = true
                        } label: {
                            Image(systemName: "book.closed")
                                .foregroundStyle(.secondary)
                        }

                        Button("저장") { saveAndDismiss() }
                            .font(.headline)
                            .foregroundStyle(canSave ? Color.pink : Color.secondary)
                            .disabled(!canSave)
                    }
                }
            }
            .sheet(isPresented: $showList) {
                JournalListView()
                    .environmentObject(journal)
            }
        }
        .onAppear {
            if let editing {
                text = editing.text
                mood = editing.mood
            }
            chosenPrompt = prompts.randomElement() ?? prompts[0]
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                focused = true
            }
        }
    }

    private var paperBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 1.00, green: 0.96, blue: 0.93),
                    Color(red: 0.98, green: 0.94, blue: 0.98)
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            GeometryReader { geo in
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 160, height: 160)
                        .blur(radius: 40)
                        .offset(
                            x: CGFloat(i % 2 == 0 ? 1 : -1) * (geo.size.width * 0.3),
                            y: CGFloat(i) * (geo.size.height * 0.28)
                        )
                }
            }
            .allowsHitTesting(false)
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 14) {
            Text("૮ ˶ᵔ ᵕ ᵔ˶ ა")
                .font(.system(size: 32))

            VStack(alignment: .leading, spacing: 4) {
                Text(chosenPrompt)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color(red: 0.35, green: 0.22, blue: 0.35))
                Text("짧아도, 길어도 괜찮아. 지금 마음 그대로.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }

    private var notebookCard: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.94))
                .shadow(color: .black.opacity(0.07), radius: 10, y: 4)

            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .topLeading) {
                    if text.isEmpty {
                        Text("오늘 내 마음은…")
                            .font(.body)
                            .foregroundStyle(.secondary.opacity(0.65))
                            .padding(.top, 8)
                            .padding(.leading, 4)
                    }

                    TextEditor(text: $text)
                        .font(.body)
                        .scrollContentBackground(.hidden)
                        .focused($focused)
                        .frame(minHeight: 220)
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
            .padding(18)
        }
    }

    private var moodChips: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("오늘의 마음")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                ForEach(EmotionType.allCases.filter { $0 != .talk }) { emotion in
                    moodChip(emotion)
                }
                clearChip
            }
        }
    }

    private func moodChip(_ emotion: EmotionType) -> some View {
        let selected = mood == emotion
        return Button {
            Haptics.play(.light)
            mood = selected ? nil : emotion
        } label: {
            Text(emotion.emoji)
                .font(.system(size: 22))
                .frame(width: 40, height: 40)
                .background(
                    selected
                        ? AnyShapeStyle(
                            LinearGradient(
                                colors: [
                                    emotion.animation.primaryColor.opacity(0.9),
                                    emotion.animation.secondaryColor.opacity(0.85)
                                ],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        : AnyShapeStyle(Color.white.opacity(0.85)),
                    in: Circle()
                )
                .overlay(
                    Circle()
                        .stroke(selected ? Color.pink.opacity(0.5) : Color.gray.opacity(0.2), lineWidth: 1)
                )
                .scaleEffect(selected ? 1.05 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selected)
        }
        .buttonStyle(.plain)
    }

    private var clearChip: some View {
        Button {
            mood = nil
        } label: {
            Image(systemName: "xmark")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 40, height: 40)
                .background(.white.opacity(0.6), in: Circle())
                .overlay(
                    Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .opacity(mood == nil ? 0.3 : 1.0)
    }

    private var dateLabel: String {
        let base = editing?.createdAt ?? Date()
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M월 d일 EEEE · a h:mm"
        return f.string(from: base)
    }

    private func saveAndDismiss() {
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }

        if let editing {
            var updated = editing
            updated.text = cleaned
            updated.mood = mood
            updated.updatedAt = Date()
            journal.save(updated)
        } else {
            journal.save(
                JournalEntry(text: cleaned, mood: mood, createdAt: Date(), updatedAt: Date())
            )
        }

        Haptics.play(.soft)
        dismiss()
    }
}
