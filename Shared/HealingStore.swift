import Foundation
import WidgetKit

enum HealingStoreConfig {
    static let appGroupID = "group.com.example.healingcompanion"
    static let reactionKey = "last_reaction"
}

struct HealingStore {
    private let defaults = UserDefaults(suiteName: HealingStoreConfig.appGroupID)
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func saveReaction(_ reaction: CompanionReaction) {
        guard let defaults, let data = try? encoder.encode(reaction) else { return }
        defaults.set(data, forKey: HealingStoreConfig.reactionKey)
        WidgetCenter.shared.reloadAllTimelines()
    }

    func loadReaction() -> CompanionReaction? {
        guard let defaults,
              let data = defaults.data(forKey: HealingStoreConfig.reactionKey),
              let reaction = try? decoder.decode(CompanionReaction.self, from: data) else {
            return nil
        }
        return reaction
    }
}

enum HealingEngine {
    static let store = HealingStore()
    static let variantSelector = VariantSelector()

    static func reaction(
        for emotion: EmotionType,
        customText: String? = nil,
        now: Date = Date()
    ) -> CompanionReaction {
        let variant = variantSelector.select(for: emotion)
        return reaction(using: variant, customText: customText, now: now)
    }

    static func reaction(
        using variant: EmotionVariant,
        customText: String? = nil,
        now: Date = Date()
    ) -> CompanionReaction {
        let stylePool = HealingCatalog.styleByEmotion[variant.base] ?? [.comfort]
        let matchingCharacters = HealingCatalog.characters.filter { stylePool.contains($0.style) }
        let pickedCharacter = (matchingCharacters.isEmpty ? HealingCatalog.characters : matchingCharacters).randomElement()
            ?? HealingCatalog.characters[0]

        let pickedMessage = pickMessage(for: variant)

        return CompanionReaction(
            character: pickedCharacter,
            emotion: variant.base,
            variantID: variant.id,
            customText: customText,
            message: pickedMessage,
            expression: expressionByTime(date: now),
            createdAt: now
        )
    }

    /// Message selection rules:
    /// 1. If the user just saved a comfort message for this variant, pop it from
    ///    the pending queue and deliver it (guaranteed once).
    /// 2. Otherwise, if there are saved messages for this emotion, pick one at
    ///    random (variant-mood first, same-emotion other-mood as secondary pool).
    ///    Saved messages become the main pool — default variant messages only
    ///    appear as a fallback when nothing has been saved yet.
    /// 3. If nothing has been saved, fall back to the default variant messages.
    private static func pickMessage(for variant: EmotionVariant) -> String {
        // Step 1: guaranteed replay of the just-saved message
        if let pending = SavedComfortBank.popPending(variantID: variant.id) {
            SavedComfortBank.rememberPicked(message: pending, for: variant.id)
            if let match = SavedComfortBank.all().first(where: { $0.text == pending && $0.emotion == variant.base }) {
                SavedComfortBank.touch(id: match.id)
            }
            return pending
        }

        let variantSaved = SavedComfortBank.messages(for: variant.base, mood: variant.mood).map(\.text)
        let emotionSaved = SavedComfortBank.messages(for: variant.base).filter { $0.mood != variant.mood }.map(\.text)
        let defaultPool = variant.messages

        let lastPicked = SavedComfortBank.lastPickedMessage(for: variant.id)
        func pick(from list: [String]) -> String? {
            let filtered = list.filter { $0 != lastPicked }
            return (filtered.isEmpty ? list : filtered).randomElement()
        }

        let chosen: String
        if !variantSaved.isEmpty {
            if !emotionSaved.isEmpty, Double.random(in: 0..<1) < 0.25 {
                chosen = pick(from: emotionSaved) ?? emotionSaved[0]
            } else {
                chosen = pick(from: variantSaved) ?? variantSaved[0]
            }
        } else if !emotionSaved.isEmpty {
            chosen = pick(from: emotionSaved) ?? emotionSaved[0]
        } else if !defaultPool.isEmpty {
            chosen = pick(from: defaultPool) ?? defaultPool[0]
        } else {
            chosen = HealingCatalog.responses[variant.base]?.randomElement() ?? "괜찮아, 내가 여기 있어"
        }

        SavedComfortBank.rememberPicked(message: chosen, for: variant.id)

        if let match = SavedComfortBank.all().first(where: { $0.text == chosen && $0.emotion == variant.base }) {
            SavedComfortBank.touch(id: match.id)
        }

        return chosen
    }

    static func saveReaction(for emotion: EmotionType) {
        store.saveReaction(reaction(for: emotion))
    }

    static func saveReaction(for customText: String) {
        let base = CustomEmotionMapper.map(customText)
        let sanitized = CustomEmotionMapper.sanitize(customText)
        store.saveReaction(reaction(for: base, customText: sanitized))
    }

    static func defaultReaction(now: Date = Date()) -> CompanionReaction {
        CompanionReaction(
            id: CompanionReaction.portraitBootstrapReactionID,
            character: HealingCatalog.characters[0],
            emotion: .talk,
            variantID: "talk.quiet",
            customText: nil,
            message: "네가 떠오르면 여기 있을게",
            expression: expressionByTime(date: now),
            createdAt: now
        )
    }

    static func expressionByTime(date: Date) -> String {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 0..<6: return "졸린 밤"
        case 6..<12: return "차분한 아침"
        case 12..<18: return "포근한 낮"
        case 18..<22: return "따뜻한 저녁"
        default: return "조용한 밤"
        }
    }

    static func subtleMessageByTime(date: Date) -> String {
        let hour = Calendar.current.component(.hour, from: date)
        let checkpoint = HealingCatalog.hourlyMoodMessages.keys.filter { $0 <= hour }.max() ?? 0
        return HealingCatalog.hourlyMoodMessages[checkpoint] ?? "천천히 가도 좋아"
    }
}
