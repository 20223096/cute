import SwiftUI
import UIKit
import WidgetKit

struct HealingEntry: TimelineEntry {
    let date: Date
    let reaction: CompanionReaction
    let subtleMessage: String
    let burst: Bool
}

struct HealingProvider: TimelineProvider {
    private let burstDuration: TimeInterval = 2.2

    func placeholder(in context: Context) -> HealingEntry {
        HealingEntry(
            date: .now,
            reaction: HealingEngine.defaultReaction(),
            subtleMessage: "천천히 가도 좋아",
            burst: false
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (HealingEntry) -> Void) {
        let reaction = HealingEngine.store.loadReaction() ?? HealingEngine.defaultReaction()
        completion(
            HealingEntry(
                date: .now,
                reaction: reaction,
                subtleMessage: HealingEngine.subtleMessageByTime(date: .now),
                burst: false
            )
        )
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HealingEntry>) -> Void) {
        let now = Date()
        let reaction = HealingEngine.store.loadReaction() ?? HealingEngine.defaultReaction(now: now)
        let subtle = HealingEngine.subtleMessageByTime(date: now)
        let sinceTap = now.timeIntervalSince(reaction.createdAt)

        var entries: [HealingEntry] = []

        if sinceTap >= 0, sinceTap < burstDuration {
            entries.append(
                HealingEntry(date: now, reaction: reaction, subtleMessage: subtle, burst: true)
            )
            let settleDate = reaction.createdAt.addingTimeInterval(burstDuration)
            entries.append(
                HealingEntry(date: settleDate, reaction: reaction, subtleMessage: subtle, burst: false)
            )
        } else {
            entries.append(
                HealingEntry(date: now, reaction: reaction, subtleMessage: subtle, burst: false)
            )
        }

        let next = Calendar.current.date(byAdding: .hour, value: 1, to: now) ?? now.addingTimeInterval(3600)
        completion(Timeline(entries: entries, policy: .after(next)))
    }
}

// MARK: - Healy (번들 `home_mood_n`) — WidgetKit는 SwiftUI `Image`가 `UIViewRepresentable`보다 안정적

private struct WidgetHealyPortrait: View {
    let reaction: CompanionReaction
    var size: CGFloat

    private var imageName: String { "home_mood_\(reaction.homeMoodImageIndex)" }

    var body: some View {
        Group {
            if let image = UIImage(named: imageName, in: .main, compatibleWith: nil) {
                Image(uiImage: image)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
            } else {
                Text(reaction.emotion.emoji)
                    .font(.system(size: size * 0.55))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(width: size, height: size, alignment: .center)
        .contentShape(Rectangle())
        .accessibilityHidden(true)
    }
}

/// 밤(어두운 그라데이션)일 때 제목/캡션 가독성
private struct WidgetNightTitleShadow: ViewModifier {
    var isNight: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if isNight {
            content.shadow(color: .black.opacity(0.45), radius: 0, x: 0, y: 1.2)
        } else {
            content
        }
    }
}

struct HealingWidgetEntryView: View {
    var entry: HealingProvider.Entry
    @Environment(\.widgetFamily) private var family

    private var isNightTime: Bool {
        let h = Calendar.current.component(.hour, from: entry.date)
        return h < 7 || h > 20
    }

    private var isBurst: Bool { entry.burst }

    /// 그라데이션 위 (이름·캡션) — 배경 모드별 대비색 (순백 지양)
    private var onGradientTitle: Color {
        if isBurst { return Color(red: 0.22, green: 0.1, blue: 0.08) }
        if isNightTime { return Color(red: 1.0, green: 0.92, blue: 0.72) }
        return Color(red: 0.06, green: 0.08, blue: 0.28)
    }

    private var onGradientCaption: Color {
        if isBurst { return Color(red: 0.4, green: 0.22, blue: 0.18) }
        if isNightTime { return Color(red: 0.76, green: 0.84, blue: 1.0) }
        return Color(red: 0.16, green: 0.18, blue: 0.34)
    }

    /// 멘트 카드 — 낮은 밝은 패널+남색 글자, 밤은 짙은 패널+라벤더 글자, 버스트는 살구 배경+적갈색 글자
    private var cardFill: Color {
        if isBurst { return Color(red: 1.0, green: 0.93, blue: 0.86) }
        if isNightTime { return Color(red: 0.13, green: 0.11, blue: 0.26).opacity(0.94) }
        return Color(red: 0.96, green: 0.97, blue: 1.0)
    }

    private var cardPrimaryText: Color {
        if isBurst { return Color(red: 0.44, green: 0.18, blue: 0.14) }
        if isNightTime { return Color(red: 0.9, green: 0.91, blue: 1.0) }
        return Color(red: 0.08, green: 0.09, blue: 0.24)
    }

    private var cardStroke: Color {
        if isBurst { return Color.orange.opacity(0.38) }
        if isNightTime { return Color(red: 0.55, green: 0.62, blue: 0.98).opacity(0.42) }
        return Color.blue.opacity(0.18)
    }

    /// 이모지 버튼 칩 — 배경과 조화 (순백 피함)
    private var emojiChipIdle: Color {
        if isBurst { return Color(red: 1.0, green: 0.82, blue: 0.72).opacity(0.82) }
        if isNightTime { return Color(red: 0.28, green: 0.26, blue: 0.48).opacity(0.88) }
        return Color(red: 0.94, green: 0.96, blue: 1.0).opacity(0.92)
    }

    private var emojiChipActive: Color {
        if isBurst { return Color(red: 1.0, green: 0.94, blue: 0.78) }
        if isNightTime { return Color(red: 0.65, green: 0.62, blue: 0.92) }
        return Color(red: 1.0, green: 0.98, blue: 1.0)
    }

    private var emojiChipStroke: Color {
        if isBurst { return Color.orange.opacity(0.55) }
        if isNightTime { return Color(red: 0.65, green: 0.72, blue: 1.0).opacity(0.55) }
        return Color.blue.opacity(0.22)
    }

    private var portraitSize: CGFloat {
        switch family {
        case .systemSmall: return 45
        case .systemMedium: return 53
        case .systemLarge, .systemExtraLarge: return 82
        default: return 53
        }
    }

    /// 시간대 멘트(예: 따뜻한 저녁처럼) — 그라데이션 위 오른쪽 상단
    private var subtleCornerFontSize: CGFloat {
        switch family {
        case .systemSmall: return 7
        case .systemMedium: return 7.5
        case .systemLarge, .systemExtraLarge: return 8.5
        default: return 7.5
        }
    }

    private var subtleCornerMaxWidth: CGFloat {
        switch family {
        case .systemSmall: return 96
        case .systemMedium: return 135
        case .systemLarge, .systemExtraLarge: return 168
        default: return 135
        }
    }

    private var subtleTimeCornerLabel: some View {
        Text(entry.subtleMessage)
            .font(.system(size: subtleCornerFontSize, weight: .medium))
            .foregroundStyle(onGradientCaption)
            .multilineTextAlignment(.trailing)
            .lineLimit(2)
            .minimumScaleFactor(0.62)
            .frame(maxWidth: subtleCornerMaxWidth, alignment: .trailing)
            .modifier(WidgetNightTitleShadow(isNight: isNightTime && !isBurst))
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }

    var body: some View {
        Group {
            switch family {
            case .systemSmall: smallFamilyLayout
            case .systemLarge, .systemExtraLarge: largeFamilyLayout
            default: mediumFamilyLayout
            }
        }
        // 위젯이 주는 전체 셀 크기를 채워야 overlay의 topTrailing이 진짜 오른쪽 위로 간다
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .overlay(alignment: .topTrailing) {
            subtleTimeCornerLabel
                .padding(.top, 3)
                .padding(.trailing, 3)
        }
        .padding(.horizontal, 2)
        .padding(.vertical, 1)
        .containerBackground(for: .widget) {
            entryBackgroundFill
        }
    }

    /// `containerBackground`는 시스템이 셀 모서리에 맞게 그라데이션을 깎아 줌. 본문에 maxHeight는 주지 않음.
    private var entryBackgroundFill: some View {
        let hour = Calendar.current.component(.hour, from: entry.date)
        let dayColors = [Color.pink.opacity(0.4), Color.blue.opacity(0.3)]
        let nightColors = [Color.indigo.opacity(0.55), Color.purple.opacity(0.4)]
        let burstColors = [Color.yellow.opacity(0.6), Color.pink.opacity(0.5)]

        let colors: [Color]
        if entry.burst {
            colors = burstColors
        } else if hour < 7 || hour > 20 {
            colors = nightColors
        } else {
            colors = dayColors
        }

        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private var smallFamilyLayout: some View {
        VStack(alignment: .center, spacing: 1) {
            HStack {
                Spacer(minLength: 0)
                WidgetHealyPortrait(reaction: entry.reaction, size: portraitSize)
                Spacer(minLength: 0)
            }
            messageBlockSmall
            emojiRowCompact
                .padding(.top, 7)
        }
    }

    private var mediumFamilyLayout: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack {
                Spacer(minLength: 0)
                WidgetHealyPortrait(reaction: entry.reaction, size: portraitSize)
                Spacer(minLength: 0)
            }
            VStack(alignment: .center, spacing: 0) {
                Text(entry.reaction.character.name)
                    .font(.system(size: 11.5, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
                    .foregroundStyle(onGradientTitle)
                Text(entry.reaction.expression)
                    .font(.system(size: 8.5))
                    .lineLimit(1)
                    .foregroundStyle(onGradientCaption)
            }
            .padding(.top, 1)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            .allowsHitTesting(false)
            .modifier(WidgetNightTitleShadow(isNight: isNightTime && !isBurst))
            messageBlockMedium
            emojiRowTight
                .padding(.top, 7)
        }
    }

    private var largeFamilyLayout: some View {
        VStack(alignment: .center, spacing: 2) {
            HStack {
                Spacer(minLength: 0)
                WidgetHealyPortrait(reaction: entry.reaction, size: portraitSize)
                Spacer(minLength: 0)
            }
            VStack(alignment: .center, spacing: 0) {
                Text(entry.reaction.character.name)
                    .font(.system(size: 13.5, weight: .semibold))
                    .lineLimit(1)
                    .foregroundStyle(onGradientTitle)
                Text(entry.reaction.expression)
                    .font(.system(size: 10.5))
                    .lineLimit(1)
                    .foregroundStyle(onGradientCaption)
            }
            .padding(.top, 1)
            .frame(maxWidth: .infinity)
            .modifier(WidgetNightTitleShadow(isNight: isNightTime && !isBurst))
            messageBlockLarge
            emojiRow
                .padding(.top, 7)
        }
    }

    private var messageBlockSmall: some View {
        VStack(alignment: .center, spacing: 1) {
            Text(entry.reaction.message)
                .font(.system(size: 9.5, weight: .medium))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
                .foregroundStyle(cardPrimaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 3)
        .padding(.vertical, 2)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(cardFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(cardStroke, lineWidth: 1)
        )
        .allowsHitTesting(false)
        .id("msgS-\(entry.reaction.id)")
    }

    private var messageBlockMedium: some View {
        VStack(alignment: .center, spacing: 2) {
            Text(entry.reaction.message)
                .font(.system(size: 9.5, weight: .medium))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
                .foregroundStyle(cardPrimaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 5)
        .padding(.vertical, 3)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(cardFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(cardStroke, lineWidth: 1)
        )
        .allowsHitTesting(false)
        .id("msgM-\(entry.reaction.id)")
    }

    private var messageBlockLarge: some View {
        VStack(alignment: .center, spacing: 2) {
            Text(entry.reaction.message)
                .font(.system(size: 10.5, weight: .medium))
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.75)
                .foregroundStyle(cardPrimaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(cardFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(cardStroke, lineWidth: 1)
        )
        .allowsHitTesting(false)
        .id("msgL-\(entry.reaction.id)")
    }

    private var emojiRow: some View {
        emotionButtons(spacing: 1, fontSize: 11.5, verticalPad: 1, corner: 6)
    }

    private var emojiRowTight: some View {
        emotionButtons(spacing: 1, fontSize: 10.5, verticalPad: 1, corner: 5)
    }

    private var emojiRowCompact: some View {
        emotionButtons(spacing: 1, fontSize: 10.5, verticalPad: 1, corner: 4)
    }

    private func emotionButtons(
        spacing: CGFloat,
        fontSize: CGFloat,
        verticalPad: CGFloat,
        corner: CGFloat
    ) -> some View {
        let emotions: [EmotionAppEnum] = [.tired, .rest, .annoyed, .numb, .worthless, .talk]
        let activeRaw = entry.reaction.emotion.rawValue

        return VStack(spacing: 1) {
            HStack(spacing: spacing) {
                ForEach(Array(emotions.prefix(3)), id: \.rawValue) { emotion in
                    emotionButton(emotion, activeRaw: activeRaw, fontSize: fontSize, verticalPad: verticalPad, corner: corner)
                }
            }
            HStack(spacing: spacing) {
                ForEach(Array(emotions.suffix(3)), id: \.rawValue) { emotion in
                    emotionButton(emotion, activeRaw: activeRaw, fontSize: fontSize, verticalPad: verticalPad, corner: corner)
                }
            }
        }
    }

    private func emotionButton(
        _ emotion: EmotionAppEnum,
        activeRaw: String,
        fontSize: CGFloat,
        verticalPad: CGFloat,
        corner: CGFloat
    ) -> some View {
        let isActive = entry.burst && emotion.rawValue == activeRaw
        return Button(intent: SelectEmotionIntent(emotion: emotion)) {
            Text(emoji(for: emotion))
                .font(.system(size: fontSize))
                .frame(maxWidth: .infinity)
                .padding(.vertical, verticalPad)
                .background(
                    RoundedRectangle(cornerRadius: corner)
                        .fill(isActive ? emojiChipActive : emojiChipIdle)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: corner)
                        .stroke(
                            isActive ? emojiChipStroke.opacity(0.95) : emojiChipStroke.opacity(0.35),
                            lineWidth: 1.0
                        )
                )
        }
        .buttonStyle(.plain)
    }

    private func emoji(for emotion: EmotionAppEnum) -> String {
        switch emotion {
        case .tired: return "😭"
        case .rest: return "😴"
        case .annoyed: return "😡"
        case .numb: return "😶"
        case .worthless: return "🥀"
        case .talk: return "💬"
        }
    }
}

struct HealingWidget: Widget {
    let kind: String = "HealingWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HealingProvider()) { entry in
            HealingWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Healing Companion")
        .description("이모지를 누르면 힐리와 짧은 멘트가 곁에 머물어요")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}
