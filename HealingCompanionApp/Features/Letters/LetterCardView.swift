import SwiftUI

struct LetterCardView: View {
    let letter: EmotionLetter
    var compact: Bool = false
    var onTap: () -> Void = {}

    @State private var wiggle = false
    @State private var floatUp = false

    private var anim: EmotionAnimation { letter.emotion.animation }
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                envelope
                details
                Spacer(minLength: 0)
                chevron
            }
            .padding(compact ? 10 : 14)
            .background(backgroundFill, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(0.5), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
            .offset(y: floatUp ? -2 : 2)
            .rotationEffect(.degrees(wiggle ? 1.4 : -1.4), anchor: .bottom)
            .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true), value: floatUp)
            .animation(.easeInOut(duration: 2.1).repeatForever(autoreverses: true), value: wiggle)
        }
        .buttonStyle(.plain)
        .onAppear {
            if letter.isUnopened {
                floatUp = true
                wiggle = true
            }
        }
    }

    private var envelope: some View {
        ZStack(alignment: .topTrailing) {
            EnvelopeView(
                primaryColor: anim.primaryColor.opacity(0.85),
                secondaryColor: anim.secondaryColor.opacity(0.95),
                sealSymbol: nil,
                sealEmotion: letter.emotion,
                size: CGSize(width: compact ? 74 : 90, height: compact ? 52 : 62)
            )
            if letter.isUnopened {
                Circle()
                    .fill(Color.pink)
                    .frame(width: 10, height: 10)
                    .overlay(Circle().stroke(.white, lineWidth: 1.5))
                    .offset(x: 4, y: -4)
            }
        }
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Text(letter.emotion.emoji)
                    .font(.system(size: compact ? 14 : 16))
                Text(directionLabel)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary.opacity(0.85))
            }
            Text(letter.isUnopened ? "열어보지 않은 편지" : letter.message)
                .font(.subheadline)
                .foregroundStyle(.primary.opacity(0.82))
                .lineLimit(1)
            Text(dateLine)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private var chevron: some View {
        Image(systemName: "chevron.right")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
    }

    private var backgroundFill: some ShapeStyle {
        LinearGradient(
            colors: [
                Color.white.opacity(letter.isUnopened ? 0.95 : 0.88),
                anim.primaryColor.opacity(letter.isUnopened ? 0.4 : 0.22)
            ],
            startPoint: .leading, endPoint: .trailing
        )
    }

    private var directionLabel: String {
        switch letter.direction {
        case .incoming: return "\(letter.senderName)에게서"
        case .outgoing: return "\(letter.recipientName)에게"
        }
    }

    private var dateLine: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M월 d일 a h:mm"
        return f.string(from: letter.sentAt)
    }
}
