import Foundation

struct DaySummary: Identifiable, Hashable {
    var id: Date { day }
    let day: Date
    let moments: [EmotionEntry]

    var count: Int { moments.count }

    var emotionsInOrder: [EmotionType] {
        var seen: Set<EmotionType> = []
        var result: [EmotionType] = []
        for m in moments where !seen.contains(m.emotion) {
            seen.insert(m.emotion)
            result.append(m.emotion)
        }
        return result
    }

    var dominantEmotion: EmotionType? {
        guard !moments.isEmpty else { return nil }
        let counts = Dictionary(grouping: moments, by: { $0.emotion }).mapValues { $0.count }
        return counts.max(by: { a, b in
            if a.value != b.value { return a.value < b.value }
            return lastTime(for: a.key) < lastTime(for: b.key)
        })?.key
    }

    private func lastTime(for emotion: EmotionType) -> Date {
        moments.last(where: { $0.emotion == emotion })?.date ?? .distantPast
    }

    var recapLine: String {
        DayRecap.build(for: self)
    }
}

enum DayRecap {
    static func build(for summary: DaySummary) -> String {
        let moments = summary.moments
        guard !moments.isEmpty else { return "" }

        let uniques = summary.emotionsInOrder

        if moments.count == 1, let only = moments.first {
            return "오늘 너는 \(only.emotion.emoji) \(label(only.emotion))의 순간을 보냈어. 그거면 돼."
        }

        if uniques.count == 1, let one = uniques.first {
            return "오늘 하루는 \(one.emoji) \(label(one))의 하루였어. 애썼어, 오늘도."
        }

        let emojiTrail = uniques.map(\.emoji).joined(separator: "  ")

        if let dominant = summary.dominantEmotion,
           moments.filter({ $0.emotion == dominant }).count * 2 >= moments.count {
            return "오늘 너는 \(emojiTrail) 사이를 오갔어. 그중에서도 \(dominant.emoji) \(label(dominant))이 자주 찾아왔지. 그런 하루였어."
        }

        return "오늘 너는 \(emojiTrail) 이런 마음들을 지나왔어. 여러 결의 하루였고, 그걸 다 느낀 것만으로 충분해."
    }

    static func label(_ emotion: EmotionType) -> String {
        switch emotion {
        case .tired: return "지친 마음"
        case .rest: return "쉬고 싶은 마음"
        case .annoyed: return "짜증"
        case .numb: return "무감한 마음"
        case .worthless: return "작아진 마음"
        case .talk: return "털어놓고 싶은 마음"
        }
    }
}
