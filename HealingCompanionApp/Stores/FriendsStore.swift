import Foundation
import SwiftUI

enum FriendReactionKind: String, Codable, CaseIterable, Identifiable {
    case heart
    case hug
    case sparkle
    case tea

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .heart: return "♡"
        case .hug: return "🤗"
        case .sparkle: return "✦"
        case .tea: return "🍵"
        }
    }

    var label: String {
        switch self {
        case .heart: return "마음"
        case .hug: return "안아줄게"
        case .sparkle: return "빛"
        case .tea: return "차 한 잔"
        }
    }
}

struct Friend: Identifiable, Hashable {
    let id: String
    let name: String
    let characterID: String
    let inviteCode: String
    var recentEntries: [EmotionEntry]
    var receivedReactions: [UUID: [FriendReactionKind]] = [:]

    var character: CompanionCharacter {
        HealingCatalog.characters.first(where: { $0.id == characterID })
            ?? HealingCatalog.characters[0]
    }

    static func == (lhs: Friend, rhs: Friend) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

@MainActor
final class FriendsStore: ObservableObject {
    @Published var friends: [Friend]

    init() {
        self.friends = FriendsStore.makeMock()
    }

    func toggleReaction(_ kind: FriendReactionKind, on entryID: UUID, friendID: String) {
        guard let idx = friends.firstIndex(where: { $0.id == friendID }) else { return }
        var list = friends[idx].receivedReactions[entryID, default: []]
        if let pos = list.firstIndex(of: kind) {
            list.remove(at: pos)
        } else {
            list.append(kind)
        }
        friends[idx].receivedReactions[entryID] = list
    }

    private static func makeMock() -> [Friend] {
        let cal = Calendar.current
        let now = Date()

        func entries(_ config: [(Int, EmotionType)]) -> [EmotionEntry] {
            config.compactMap { offset, emotion in
                guard let date = cal.date(byAdding: .day, value: offset, to: now) else { return nil }
                let character = HealingCatalog.characters.randomElement() ?? HealingCatalog.characters[0]
                let msg = HealingCatalog.responses[emotion]?.randomElement() ?? ""
                return EmotionEntry(
                    date: cal.startOfDay(for: date),
                    emotion: emotion,
                    characterID: character.id,
                    message: msg
                )
            }
        }

        return [
            Friend(
                id: "f_yuri",
                name: "유리",
                characterID: "healy",
                inviteCode: "YURI-7421",
                recentEntries: entries([(0, .rest), (-1, .tired), (-2, .talk), (-4, .numb)])
            ),
            Friend(
                id: "f_sumin",
                name: "수민",
                characterID: "healy",
                inviteCode: "SUMIN-8830",
                recentEntries: entries([(0, .talk), (-1, .talk), (-3, .annoyed), (-5, .rest)])
            ),
            Friend(
                id: "f_dohee",
                name: "도희",
                characterID: "healy",
                inviteCode: "DOHEE-2210",
                recentEntries: entries([(-1, .numb), (-2, .tired), (-3, .rest), (-6, .talk)])
            )
        ]
    }
}
