import Foundation

struct CustomEmotion: Identifiable, Codable, Hashable {
    let id: UUID
    let text: String
    let mappedBase: EmotionType
    let createdAt: Date

    init(
        id: UUID = UUID(),
        text: String,
        mappedBase: EmotionType,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.text = text
        self.mappedBase = mappedBase
        self.createdAt = createdAt
    }
}

enum CustomEmotionMapper {
    private static let keywordMap: [EmotionType: [String]] = [
        .tired: [
            "피곤", "지침", "지쳐", "힘들", "힘들어", "울", "눈물", "울고", "터질",
            "무거워", "버거", "눈물나", "슬퍼", "슬픔", "처져", "울먹"
        ],
        .rest: [
            "쉬고", "쉼", "자고", "잠", "졸려", "눕고", "드러눕", "멈추고",
            "침대", "이불", "늘어지", "누워"
        ],
        .annoyed: [
            "짜증", "빡", "빡쳐", "화", "분노", "열받", "싫어", "미워", "욱",
            "억울", "답답", "꼴보기", "킹받"
        ],
        .numb: [
            "멍", "모르겠", "허무", "공허", "무감각", "아무", "노잼", "무기력",
            "애매", "어정쩡", "흐려", "뿌옇"
        ],
        .worthless: [
            "자존감", "자책", "쓸모", "못난", "가치", "부끄럽", "한심", "바보",
            "쪼그라", "작아져", "우울", "비참", "의미 없", "못 살"
        ],
        .talk: [
            "얘기", "말하고", "대화", "들어", "들어줘", "수다", "말", "하소연",
            "재잘", "떠들"
        ]
    ]

    static func map(_ raw: String) -> EmotionType {
        let text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return .talk }

        var scores: [EmotionType: Int] = [:]
        for (emotion, keywords) in keywordMap {
            var score = 0
            for keyword in keywords where text.localizedStandardContains(keyword) {
                score += keyword.count
            }
            if score > 0 {
                scores[emotion] = score
            }
        }

        if let best = scores.max(by: { $0.value < $1.value })?.key {
            return best
        }

        if text.contains("?") || text.contains("??") {
            return .talk
        }
        return .talk
    }

    static func sanitize(_ raw: String) -> String {
        String(
            raw
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .prefix(24)
        )
    }
}
