import SwiftUI

struct ComfortToastPayload: Identifiable, Equatable {
    let id = UUID()
    let emotion: EmotionType
    let mood: VariantMood
    let text: String
    let caption: String
}

struct ComfortToastView: View {
    let payload: ComfortToastPayload
    var onDismiss: () -> Void = {}

    @State private var appeared = false

    private var anim: EmotionAnimation { payload.emotion.animation }

    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                Text("૮ ˶ᵔ ᵕ ᵔ˶ ა")
                    .font(.system(size: 30))
                    .scaleEffect(appeared ? 1.0 : 0.7)
                    .animation(.spring(response: 0.45, dampingFraction: 0.6), value: appeared)

                VStack(alignment: .leading, spacing: 4) {
                    Text(payload.caption)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary.opacity(0.9))
                    HStack(spacing: 6) {
                        Text(payload.emotion.emoji)
                            .font(.system(size: 14))
                        Text("“\(payload.text)”")
                            .font(.caption)
                            .foregroundStyle(.primary.opacity(0.7))
                            .lineLimit(1)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.98),
                        anim.primaryColor.opacity(0.55)
                    ],
                    startPoint: .leading, endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: 22, style: .continuous)
            )
            .shadow(color: .black.opacity(0.1), radius: 12, y: 4)
            .padding(.horizontal, 16)
            .offset(y: appeared ? 0 : 120)
            .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                appeared = true
            }
            Haptics.play(.soft)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
                withAnimation(.easeInOut(duration: 0.35)) {
                    appeared = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    onDismiss()
                }
            }
        }
    }
}

enum ComfortToastCopy {
    static let lines: [String] = [
        "다음에 이 감정을 누르면 이 말을 들려줄게",
        "이 감정에 이 말을 담아둘게",
        "다음엔 이 위로를 먼저 건네볼게",
        "네가 듣고 싶었던 말, 잘 기억해 둘게",
        "담아뒀어. 필요할 때 꺼내줄게"
    ]
    static func random() -> String { lines.randomElement() ?? lines[0] }
}

struct ComfortToastModifier: ViewModifier {
    @Binding var payload: ComfortToastPayload?

    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content

            if let payload {
                ComfortToastView(payload: payload) {
                    self.payload = nil
                }
                .padding(.bottom, 30)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(10)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: payload?.id)
    }
}

extension View {
    func comfortToast(_ payload: Binding<ComfortToastPayload?>) -> some View {
        modifier(ComfortToastModifier(payload: payload))
    }
}
