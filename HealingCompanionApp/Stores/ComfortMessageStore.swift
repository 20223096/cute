import Foundation
import SwiftUI

@MainActor
final class ComfortMessageStore: ObservableObject {
    @Published private(set) var messages: [SavedComfortMessage] = []

    init() {
        reload()
    }

    func reload() {
        messages = SavedComfortBank.all().sorted { $0.createdAt > $1.createdAt }
    }

    @discardableResult
    func save(
        text rawText: String,
        overrideEmotion: EmotionType? = nil,
        overrideMood: VariantMood? = nil
    ) -> SavedComfortMessage? {
        let text = ComfortMapper.sanitize(rawText)
        guard !text.isEmpty else { return nil }

        let autoMapping = ComfortMapper.map(text)
        let emotion = overrideEmotion ?? autoMapping.emotion
        let mood = overrideMood ?? (overrideEmotion == nil ? autoMapping.mood : autoMapping.mood)
        let variant = ComfortMapper.variant(for: emotion, mood: mood)
        let overridden = overrideEmotion != nil || overrideMood != nil

        let entry = SavedComfortMessage(
            text: text,
            emotion: emotion,
            mood: mood,
            variantID: variant.id,
            userOverridden: overridden
        )
        SavedComfortBank.upsert(entry)
        // Guarantee this message plays exactly once the next time the user taps
        // this emotion variant.
        SavedComfortBank.pushPending(text: entry.text, variantID: variant.id)
        reload()
        return entry
    }

    func delete(_ entry: SavedComfortMessage) {
        if let variantID = entry.variantID {
            SavedComfortBank.removePending(text: entry.text, variantID: variantID)
        }
        SavedComfortBank.remove(id: entry.id)
        reload()
    }

    func messages(for emotion: EmotionType, mood: VariantMood? = nil) -> [SavedComfortMessage] {
        messages.filter { saved in
            guard saved.emotion == emotion else { return false }
            if let mood { return saved.mood == mood }
            return true
        }
    }
}
