import SwiftUI

struct EmotionDayDetailView: View {
    let summary: DaySummary
    @Environment(\.dismiss) private var dismiss
    @State private var replayMoment: EmotionEntry?

    private var cal: Calendar { Calendar.current }
    private var dominant: EmotionType {
        summary.dominantEmotion ?? summary.moments.first?.emotion ?? .numb
    }
    private var anim: EmotionAnimation { dominant.animation }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [anim.primaryColor.opacity(0.6), anim.secondaryColor.opacity(0.35)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                ScrollView {
                    VStack(spacing: 20) {
                        recapCard
                        timelineSection
                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .padding(.bottom, 30)
                }
            }
        }
        .fullScreenCover(item: $replayMoment) { moment in
            AnimationSceneView(
                emotion: moment.emotion,
                character: moment.character,
                message: moment.message
            ) {
                replayMoment = nil
            }
        }
    }

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.primary.opacity(0.55))
            }
            Spacer()
            Text(dateString)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary.opacity(0.8))
            Spacer()
            Color.clear.frame(width: 28, height: 28)
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 10)
    }

    private var recapCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Text("오늘 너가 느꼈던 감정들이야")
                    .font(.headline)
                    .foregroundStyle(.primary.opacity(0.85))
                Spacer()
                Text("\(summary.count)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.black.opacity(0.45), in: Capsule())
            }

            HStack(spacing: 6) {
                ForEach(summary.emotionsInOrder, id: \.self) { emotion in
                    Text(emotion.emoji)
                        .font(.system(size: 30))
                }
            }

            Text(summary.recapLine)
                .font(.subheadline)
                .foregroundStyle(.primary.opacity(0.78))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 10, y: 4)
    }

    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("하루의 순간들")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                ForEach(Array(summary.moments.enumerated()), id: \.element.id) { index, moment in
                    momentRow(moment, isLast: index == summary.moments.count - 1)
                }
            }
            .padding(14)
            .background(.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
    }

    private func momentRow(_ moment: EmotionEntry, isLast: Bool) -> some View {
        Button {
            replayMoment = moment
        } label: {
            HStack(alignment: .top, spacing: 12) {
                VStack(spacing: 4) {
                    Text(timeString(moment.date))
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(.secondary)
                    ZStack {
                        Circle()
                            .fill(moment.emotion.animation.primaryColor.opacity(0.6))
                            .frame(width: 32, height: 32)
                        Text(moment.emotion.emoji)
                            .font(.system(size: 18))
                    }
                    if !isLast {
                        Rectangle()
                            .fill(Color.primary.opacity(0.08))
                            .frame(width: 1.5)
                            .frame(minHeight: 24)
                    }
                }
                .frame(width: 44)

                VStack(alignment: .leading, spacing: 4) {
                    Text(moment.character.name)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.primary.opacity(0.7))
                    Text(moment.message)
                        .font(.subheadline)
                        .foregroundStyle(.primary.opacity(0.9))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                Image(systemName: "play.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.primary.opacity(0.35))
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }

    private var dateString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy년 M월 d일 EEEE"
        return f.string(from: summary.day)
    }

    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "a h:mm"
        return f.string(from: date)
    }
}
