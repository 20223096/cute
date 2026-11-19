import Foundation

extension CompanionReaction {
    /// 최초·기본 반응 — 홈/위젯 포트레이트는 `home_mood_0` 고정.
    static let portraitBootstrapReactionID = UUID(uuidString: "F0000000-0000-4000-8000-000000000001")!

    /// `home_mood_{index}` — 😭→1 … 🥀→5. 💬는 번들 6장 한계로 `home_mood_5`와 동일.
    var homeMoodImageIndex: Int {
        if id == Self.portraitBootstrapReactionID {
            return 0
        }
        switch emotion {
        case .tired: return 1
        case .rest: return 2
        case .annoyed: return 3
        case .numb: return 4
        case .worthless: return 5
        case .talk: return 5
        }
    }
}
