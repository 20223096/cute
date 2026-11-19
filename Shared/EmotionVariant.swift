import Foundation

enum VariantMood: String, Codable, CaseIterable, Hashable {
    case quiet
    case active
    case silent
    case ack

    var label: String {
        switch self {
        case .quiet: return "조용한 위로"
        case .active: return "다가와 주는 위로"
        case .silent: return "말없이 옆에"
        case .ack: return "그랬구나"
        }
    }
}

struct EmotionVariant: Identifiable, Codable, Hashable {
    let id: String
    let base: EmotionType
    let mood: VariantMood
    let label: String
    let messages: [String]
}

enum EmotionVariantCatalog {
    static let all: [EmotionVariant] = [
        // MARK: - 😭 tired
        EmotionVariant(
            id: "tired.quiet",
            base: .tired,
            mood: .quiet,
            label: "가만히 옆에",
            messages: [
                "너의 아픔도 슬픔도, 눈물까지 다 떠내려가 버렸으면 좋겠어",
                "울어도 괜찮아",
                "지금 이 순간만 여기 있자"
            ]
        ),
        EmotionVariant(
            id: "tired.active",
            base: .tired,
            mood: .active,
            label: "떠내려 보내기",
            messages: [
                "너의 아픔도 슬픔도, 눈물까지 다 떠내려가 버렸으면 좋겠어",
                "내가 옆에 있을게",
                "바다까지 데려다 줄게, 마음만 실어"
            ]
        ),
        EmotionVariant(
            id: "tired.silent",
            base: .tired,
            mood: .silent,
            label: "그냥 함께",
            messages: []
        ),
        EmotionVariant(
            id: "tired.ack",
            base: .tired,
            mood: .ack,
            label: "고생했어",
            messages: [
                "너의 아픔도 슬픔도, 눈물까지 다 떠내려가 버렸으면 좋겠어",
                "오늘 진짜 고생했어",
                "버틴 거 대단해"
            ]
        ),

        // MARK: - 😴 rest
        EmotionVariant(
            id: "rest.active",
            base: .rest,
            mood: .active,
            label: "이불 덮어주기",
            messages: [
                "잠깐 쉬어가도 돼",
                "이불 덮고 한숨 돌리자",
                "포근해, 천천히 와"
            ]
        ),
        EmotionVariant(
            id: "rest.quiet",
            base: .rest,
            mood: .quiet,
            label: "조용히 쉬기",
            messages: [
                "잠깐 쉬어가도 돼",
                "눈만 감고 있어도 돼",
                "시간은 천천히 흐르게 두자"
            ]
        ),
        EmotionVariant(
            id: "rest.silent",
            base: .rest,
            mood: .silent,
            label: "같이 멍때리기",
            messages: []
        ),
        EmotionVariant(
            id: "rest.ack",
            base: .rest,
            mood: .ack,
            label: "쉬어도 돼",
            messages: [
                "잠깐 쉬어가도 돼",
                "오늘은 그냥 비워도 돼",
                "쉼도 노력이야"
            ]
        ),

        // MARK: - 😡 annoyed
        EmotionVariant(
            id: "annoyed.active",
            base: .annoyed,
            mood: .active,
            label: "샌드백 퉁퉁",
            messages: [
                "담아두지 말고 다 비워냈으면 좋겠어",
                "한 방 시원하게 날려버리자",
                "퉁퉁, 괜찮아질 거야"
            ]
        ),
        EmotionVariant(
            id: "annoyed.ack",
            base: .annoyed,
            mood: .ack,
            label: "그럴 만했어",
            messages: [
                "담아두지 말고 다 비워냈으면 좋겠어",
                "화 날 만해, 응",
                "네 잘못 아니야"
            ]
        ),
        EmotionVariant(
            id: "annoyed.quiet",
            base: .annoyed,
            mood: .quiet,
            label: "후, 한숨 돌리기",
            messages: [
                "담아두지 말고 다 비워냈으면 좋겠어",
                "같이 천천히, 한 박자 쉬자",
                "욱한 건 나중에 생각해도 돼"
            ]
        ),
        EmotionVariant(
            id: "annoyed.silent",
            base: .annoyed,
            mood: .silent,
            label: "말없이 털기",
            messages: []
        ),

        // MARK: - 😶 numb
        EmotionVariant(
            id: "numb.quiet",
            base: .numb,
            mood: .quiet,
            label: "선물 같은 너",
            messages: [
                "너는 존재 자체로 선물이야",
                "너의 존재 자체가 선물인걸",
                "이대로도 충분해"
            ]
        ),
        EmotionVariant(
            id: "numb.silent",
            base: .numb,
            mood: .silent,
            label: "풍경만 함께",
            messages: []
        ),
        EmotionVariant(
            id: "numb.ack",
            base: .numb,
            mood: .ack,
            label: "알아, 그런 날 있어",
            messages: [
                "너는 존재 자체로 선물이야",
                "지금의 너도 충분해",
                "억지로 뭔가 안 해도 돼"
            ]
        ),

        // MARK: - 🥀 worthless
        EmotionVariant(
            id: "worthless.active",
            base: .worthless,
            mood: .active,
            label: "꽃 건네기",
            messages: [
                "누구도 너의 가치를 판단할 수 없어",
                "너는 그대로도 충분히 소중해",
                "작아지지 마, 여기 있어"
            ]
        ),
        EmotionVariant(
            id: "worthless.quiet",
            base: .worthless,
            mood: .quiet,
            label: "가만히 안아주기",
            messages: [
                "오늘 하루, 네가 있어서 다행이야",
                "존재만으로 이미 충분해",
                "그 마음, 내가 들고 있을게"
            ]
        ),
        EmotionVariant(
            id: "worthless.ack",
            base: .worthless,
            mood: .ack,
            label: "네 탓 아니야",
            messages: [
                "네 탓 아니야",
                "너 자체가 이유야, 다른 거 필요 없어",
                "충분히 잘해왔어"
            ]
        ),
        EmotionVariant(
            id: "worthless.silent",
            base: .worthless,
            mood: .silent,
            label: "말없이 꽃 한 송이",
            messages: []
        ),

        // MARK: - 💬 talk
        EmotionVariant(
            id: "talk.active",
            base: .talk,
            mood: .active,
            label: "귀 기울이기",
            messages: [
                "응, 여기 있어",
                "한 마디만 해도 좋아",
                "천천히 말해도 돼"
            ]
        ),
        EmotionVariant(
            id: "talk.ack",
            base: .talk,
            mood: .ack,
            label: "듣고 있어",
            messages: [
                "듣고 있어",
                "그래서?",
                "응응, 계속"
            ]
        ),
        EmotionVariant(
            id: "talk.quiet",
            base: .talk,
            mood: .quiet,
            label: "조용히 눈 맞추기",
            messages: [
                "말 안 해도 괜찮아",
                "눈만 맞춰도 돼",
                "여기, 천천히"
            ]
        ),
        EmotionVariant(
            id: "talk.silent",
            base: .talk,
            mood: .silent,
            label: "그냥 곁에",
            messages: []
        )
    ]

    static func variants(for base: EmotionType) -> [EmotionVariant] {
        all.filter { $0.base == base }
    }

    static func variant(id: String) -> EmotionVariant? {
        all.first { $0.id == id }
    }

    static func fallback(for base: EmotionType) -> EmotionVariant {
        variants(for: base).first
            ?? EmotionVariant(
                id: "\(base.rawValue).active",
                base: base,
                mood: .active,
                label: base.rawValue,
                messages: HealingCatalog.responses[base] ?? ["여기 있어"]
            )
    }
}
