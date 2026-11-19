import SwiftUI

struct LetterOpenView: View {
    let letter: EmotionLetter
    let onDismiss: () -> Void

    @EnvironmentObject private var letterStore: LetterStore

    @State private var phase: Phase = .envelopeIdle
    @State private var flapProgress: Double = 0
    @State private var envelopeScale: CGFloat = 0.9
    @State private var envelopeOpacity: Double = 0
    @State private var cardLift: CGFloat = 0
    @State private var cardOpacity: Double = 0
    @State private var sceneOpacity: Double = 0
    @State private var messageOpacity: Double = 0
    @State private var playScene = false

    private enum Phase: Equatable {
        case envelopeIdle, opening, card, scene
    }

    private var anim: EmotionAnimation { letter.emotion.animation }
    private var senderCharacter: CompanionCharacter {
        HealingCatalog.characters.first(where: { $0.id == letter.senderCharacterID })
            ?? HealingCatalog.characters[0]
    }
    private var variant: EmotionVariant {
        if let id = letter.variantID, let v = EmotionVariantCatalog.variant(id: id) { return v }
        return EmotionVariantCatalog.variants(for: letter.emotion)
            .first(where: { $0.mood == letter.mood })
            ?? EmotionVariantCatalog.fallback(for: letter.emotion)
    }

    var body: some View {
        ZStack {
            backdrop

            if playScene {
                AnimationSceneView(
                    emotion: letter.emotion,
                    character: senderCharacter,
                    message: letter.message,
                    mood: letter.mood
                ) {
                    close()
                }
                .opacity(sceneOpacity)
                .transition(.opacity)
            }

            envelopeLayer
            cardLayer

            if phase != .scene {
                topCloseButton
            }
        }
        .onAppear { startSequence() }
    }

    private var backdrop: some View {
        LinearGradient(
            colors: [
                anim.primaryColor.opacity(0.65),
                anim.secondaryColor.opacity(0.45)
            ],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()
        .overlay(Color.black.opacity(phase == .envelopeIdle ? 0.18 : 0).animation(.easeInOut(duration: 0.4), value: phase))
    }

    private var envelopeLayer: some View {
        EnvelopeView(
            primaryColor: anim.primaryColor,
            secondaryColor: anim.secondaryColor,
            sealSymbol: nil,
            sealEmotion: letter.emotion,
            size: CGSize(width: 260, height: 180),
            flapOpen: phase != .envelopeIdle,
            flapProgress: flapProgress
        )
        .scaleEffect(envelopeScale)
        .opacity(envelopeOpacity)
        .onTapGesture {
            if phase == .envelopeIdle { openEnvelope() }
        }
    }

    private var cardLayer: some View {
        VStack(spacing: 14) {
            Text(letter.senderName)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary.opacity(0.75))
            Text(letter.emotion.emoji)
                .font(.system(size: 44))
            Text(letter.message)
                .font(.title3.weight(.medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary.opacity(0.9))
                .padding(.horizontal, 22)
            Text(dateLine)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 26)
        .padding(.horizontal, 20)
        .frame(maxWidth: 300)
        .background(
            LinearGradient(
                colors: [Color.white, anim.primaryColor.opacity(0.35)],
                startPoint: .top, endPoint: .bottom
            ),
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
        .shadow(color: .black.opacity(0.15), radius: 14, y: 6)
        .offset(y: cardLift)
        .opacity(cardOpacity)
    }

    private var topCloseButton: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    close()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.8))
                        .shadow(radius: 1)
                }
                .padding(.top, 20)
                .padding(.trailing, 20)
            }
            Spacer()
        }
    }

    private var dateLine: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M월 d일 a h:mm"
        return f.string(from: letter.sentAt)
    }

    private func startSequence() {
        let wasUnopened = letter.isUnopened
        letterStore.markOpened(letter)
        withAnimation(.spring(response: 0.55, dampingFraction: 0.75)) {
            envelopeScale = 1.0
            envelopeOpacity = 1.0
        }
        if !wasUnopened {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                openEnvelope()
            }
        }
    }

    private func openEnvelope() {
        Haptics.play(.soft)
        phase = .opening
        withAnimation(.easeInOut(duration: 0.55)) {
            flapProgress = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            phase = .card
            withAnimation(.spring(response: 0.55, dampingFraction: 0.78)) {
                cardOpacity = 1.0
                cardLift = -40
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
            dissolveToScene()
        }
    }

    private func dissolveToScene() {
        playScene = true
        withAnimation(.easeInOut(duration: 0.55)) {
            envelopeOpacity = 0
            cardOpacity = 0
            sceneOpacity = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            phase = .scene
        }
    }

    private func close() {
        onDismiss()
    }
}
