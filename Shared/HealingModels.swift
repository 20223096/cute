import Foundation

enum EmotionType: String, CaseIterable, Codable, Identifiable {
    case tired
    case rest
    case annoyed
    case numb
    case worthless
    case talk

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .tired: return "😭"
        case .rest: return "😴"
        case .annoyed: return "😡"
        case .numb: return "😶"
        case .worthless: return "🥀"
        case .talk: return "💬"
        }
    }
}

enum CharacterStyle: String, CaseIterable, Codable {
    case comfort
    case playful
    case calm
    case reactive
}

struct CompanionCharacter: Identifiable, Codable {
    let id: String
    let name: String
    let style: CharacterStyle
    let face: String
}

struct CompanionReaction: Codable, Identifiable {
    let id: UUID
    let character: CompanionCharacter
    let emotion: EmotionType
    let variantID: String?
    let customText: String?
    let message: String
    let expression: String
    let createdAt: Date

    init(
        id: UUID = UUID(),
        character: CompanionCharacter,
        emotion: EmotionType,
        variantID: String? = nil,
        customText: String? = nil,
        message: String,
        expression: String,
        createdAt: Date
    ) {
        self.id = id
        self.character = character
        self.emotion = emotion
        self.variantID = variantID
        self.customText = customText
        self.message = message
        self.expression = expression
        self.createdAt = createdAt
    }
}

enum HealingCatalog {
    /// 힐리(Healy) 단일 캐릭터 — `face`는 레거시·로그용, UI는 `HealyAvatarView` 사용
    static let characters: [CompanionCharacter] = [
        CompanionCharacter(id: "healy", name: "힐리", style: .comfort, face: "🐰")
    ]

    static let responses: [EmotionType: [String]] = [
        .tired: [
            "너의 아픔도 슬픔도, 눈물까지 다 떠내려가 버렸으면 좋겠어",
            "울어도 괜찮아",
            "내가 옆에 있을게"
        ],
        .rest: [
            "잠깐 쉬어가도 돼",
            "이불 덮고 한숨 돌리자",
            "아무것도 안 해도 괜찮아"
        ],
        .annoyed: [
            "담아두지 말고 다 비워냈으면 좋겠어",
            "한 방 시원하게 날려버리자",
            "화 날 만했어, 같이 털자"
        ],
        .numb: [
            "너는 존재 자체로 선물이야",
            "지금의 너도 충분해",
            "억지로 뭔가 안 해도 돼"
        ],
        .worthless: [
            "누구도 너의 가치를 판단할 수 없어",
            "너는 그대로도 충분히 소중해",
            "작아지지 마, 여기 있어"
        ],
        .talk: [
            "응, 여기 있어",
            "한 마디만 해도 좋아",
            "천천히 말해도 돼"
        ]
    ]

    static let styleByEmotion: [EmotionType: [CharacterStyle]] = [
        .tired: [.comfort],
        .rest: [.comfort],
        .annoyed: [.comfort],
        .numb: [.comfort],
        .worthless: [.comfort],
        .talk: [.comfort]
    ]

    static let hourlyMoodMessages: [Int: String] = [
        0: "밤공기처럼 천천히",
        6: "조용히 시작해보자",
        12: "햇살 한 조각 보낼게",
        18: "오늘도 수고 많았어",
        22: "이제 마음 내려놓자"
    ]
}
