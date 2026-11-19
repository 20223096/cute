import SwiftUI

struct CustomEmotionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var customStore: CustomEmotionStore

    let onConfirm: (CustomEmotion) -> Void

    @State private var text: String = ""
    @FocusState private var focused: Bool

    private let suggestions: [String] = [
        "오늘 좀 애매함",
        "괜히 우울함",
        "설레는데 긴장됨",
        "뭔가 멍해",
        "가볍게 쉬고 싶어",
        "살짝 짜증"
    ]

    private let maxLen = 24

    private var sanitized: String {
        CustomEmotionMapper.sanitize(text)
    }

    private var previewBase: EmotionType? {
        guard !sanitized.isEmpty else { return nil }
        return CustomEmotionMapper.map(sanitized)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.94, blue: 0.96),
                        Color(red: 0.92, green: 0.95, blue: 1.0)
                    ],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        header

                        inputCard

                        if let base = previewBase {
                            previewCard(base: base)
                        }

                        suggestionBlock

                        if !customStore.recent.isEmpty {
                            recentBlock
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("닫기") { dismiss() }
                        .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("보내기") { confirm() }
                        .font(.headline)
                        .foregroundStyle(sanitized.isEmpty ? Color.secondary : Color.pink)
                        .disabled(sanitized.isEmpty)
                }
            }
        }
        .onAppear { focused = true }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("지금 마음, 한 줄")
                .font(.title3.weight(.bold))
            Text("짧게 적어주면 캐릭터가 가장 가까운 감정으로 다가가요.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var inputCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            TextField("예: 괜히 울고 싶음", text: $text, axis: .horizontal)
                .font(.title3)
                .focused($focused)
                .submitLabel(.send)
                .onSubmit(confirm)
                .onChange(of: text) { _, newValue in
                    if newValue.count > maxLen {
                        text = String(newValue.prefix(maxLen))
                    }
                }

            HStack {
                Spacer()
                Text("\(sanitized.count)/\(maxLen)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.white.opacity(0.9))
                .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
        )
    }

    private func previewCard(base: EmotionType) -> some View {
        let anim = base.animation
        return HStack(spacing: 12) {
            Text(base.emoji)
                .font(.system(size: 32))
                .frame(width: 48, height: 48)
                .background(.white.opacity(0.85), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text("가장 가까운 감정")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(baseLabel(for: base))
                    .font(.subheadline.weight(.semibold))
            }

            Spacer()

            Image(systemName: "arrow.right.circle.fill")
                .font(.title3)
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [anim.primaryColor.opacity(0.85), anim.secondaryColor.opacity(0.65)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
    }

    private var suggestionBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("예시")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            FlowLayout(spacing: 8) {
                ForEach(suggestions, id: \.self) { suggestion in
                    chip(suggestion, primary: false) {
                        text = suggestion
                    }
                }
            }
        }
    }

    private var recentBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("다시 써볼까?")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            FlowLayout(spacing: 8) {
                ForEach(customStore.recent) { entry in
                    chip("\(entry.mappedBase.emoji)  \(entry.text)", primary: true) {
                        onConfirm(entry)
                        dismiss()
                    }
                }
            }
        }
    }

    private func chip(_ text: String, primary: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(text)
                .font(.subheadline)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    primary
                        ? Color.pink.opacity(0.15)
                        : Color.white.opacity(0.85),
                    in: Capsule()
                )
                .overlay(
                    Capsule()
                        .stroke(primary ? Color.pink.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
                )
                .foregroundStyle(primary ? Color.pink : Color.primary)
        }
        .buttonStyle(.plain)
    }

    private func confirm() {
        guard !sanitized.isEmpty else { return }
        if let entry = appState.addCustomEmotion(text: sanitized) {
            Haptics.play(.soft)
            onConfirm(entry)
        }
        dismiss()
    }

    private func baseLabel(for emotion: EmotionType) -> String {
        switch emotion {
        case .tired: return "지쳤어 · 울고 싶어"
        case .rest: return "쉬고 싶어"
        case .annoyed: return "짜증 나"
        case .numb: return "내가 쓸모없게 느껴져"
        case .worthless: return "자존감이 바닥이야"
        case .talk: return "얘기하고 싶어"
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        let result = layout(subviews: subviews, in: width)
        return CGSize(width: width.isFinite ? width : result.width, height: result.height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(subviews: subviews, in: bounds.width)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                proposal: ProposedViewSize(width: frame.width, height: frame.height)
            )
        }
    }

    private func layout(subviews: Subviews, in maxWidth: CGFloat) -> (frames: [CGRect], width: CGFloat, height: CGFloat) {
        var frames: [CGRect] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxRowWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            frames.append(CGRect(x: x, y: y, width: size.width, height: size.height))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            maxRowWidth = max(maxRowWidth, x)
        }

        return (frames, maxRowWidth, y + rowHeight)
    }
}
