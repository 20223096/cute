import Foundation

struct ComfortMapping: Hashable {
    let emotion: EmotionType
    let mood: VariantMood
    let variant: EmotionVariant
}

enum ComfortMapper {
    private static let ackKeywords: [String] = [
        "괜찮", "됐", "잘했", "잘 했", "버텼", "버텨", "수고", "고생",
        "충분", "그럴 만", "그랬구나", "그래도 돼", "그런 날"
    ]
    private static let quietKeywords: [String] = [
        "쉬", "편히", "잠깐", "멈춰", "천천히", "한숨", "비워", "숨 한", "가만"
    ]
    private static let activeKeywords: [String] = [
        "줄게", "옆에", "여기", "안아", "손잡", "같이", "함께",
        "받아", "건넬", "다가", "내가"
    ]

    static func inferMood(_ raw: String) -> VariantMood {
        let text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty { return .quiet }

        let scalarCount = text.unicodeScalars.count
        if scalarCount <= 2 || text == "..." || text == "…" {
            return .silent
        }

        func score(_ keywords: [String]) -> Int {
            keywords.reduce(0) { acc, k in
                text.localizedStandardContains(k) ? acc + k.count : acc
            }
        }

        let ack = score(ackKeywords)
        let quiet = score(quietKeywords)
        let active = score(activeKeywords)

        let pairs = [(VariantMood.ack, ack), (.quiet, quiet), (.active, active)]
        if let best = pairs.max(by: { $0.1 < $1.1 }), best.1 > 0 {
            return best.0
        }
        return .quiet
    }

    static func map(_ raw: String) -> ComfortMapping {
        let emotion = CustomEmotionMapper.map(raw)
        let mood = inferMood(raw)
        let variant = EmotionVariantCatalog.variants(for: emotion)
            .first(where: { $0.mood == mood })
            ?? EmotionVariantCatalog.fallback(for: emotion)
        return ComfortMapping(emotion: emotion, mood: variant.mood, variant: variant)
    }

    static func variant(for emotion: EmotionType, mood: VariantMood) -> EmotionVariant {
        EmotionVariantCatalog.variants(for: emotion)
            .first(where: { $0.mood == mood })
            ?? EmotionVariantCatalog.fallback(for: emotion)
    }

    static func sanitize(_ raw: String) -> String {
        String(raw.trimmingCharacters(in: .whitespacesAndNewlines).prefix(25))
    }
}
