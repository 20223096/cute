import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var currentReaction: CompanionReaction
    @Published var pendingJournalRequest: Bool = false

    let emotionLog = EmotionLog()
    let friendsStore = FriendsStore()
    let customEmotionStore = CustomEmotionStore()
    let journalStore = JournalStore()
    let comfortStore = ComfortMessageStore()
    let letterStore = LetterStore()

    private var lastAppliedID: UUID?

    init() {
        if let stored = HealingEngine.store.loadReaction() {
            self.currentReaction = stored
        } else {
            let d = HealingEngine.defaultReaction()
            self.currentReaction = d
            HealingEngine.store.saveReaction(d)
        }
    }

    @discardableResult
    func triggerReaction(for emotion: EmotionType) -> CompanionReaction {
        let reaction = HealingEngine.reaction(for: emotion)
        HealingEngine.store.saveReaction(reaction)
        lastAppliedID = reaction.id
        currentReaction = reaction
        emotionLog.record(emotion: emotion, reaction: reaction)
        return reaction
    }

    @discardableResult
    func triggerReaction(for custom: CustomEmotion) -> CompanionReaction {
        let reaction = HealingEngine.reaction(for: custom.mappedBase, customText: custom.text)
        HealingEngine.store.saveReaction(reaction)
        lastAppliedID = reaction.id
        currentReaction = reaction
        emotionLog.record(emotion: custom.mappedBase, reaction: reaction)
        customEmotionStore.touch(custom)
        return reaction
    }

    @discardableResult
    func addCustomEmotion(text: String) -> CustomEmotion? {
        customEmotionStore.add(text: text)
    }

    /// Consume the reaction saved by the widget.
    /// Intentionally does NOT write to `emotionLog` — widget taps are meant to be
    /// lightweight, ephemeral comfort. Only in-app selections (Home / Animation
    /// Mode) get persisted to the personal calendar.
    func consumePendingReaction(maxAge: TimeInterval = 10) {
        guard let reaction = HealingEngine.store.loadReaction() else { return }
        let age = Date().timeIntervalSince(reaction.createdAt)
        guard age >= 0, age < maxAge else { return }
        guard reaction.id != lastAppliedID else { return }
        lastAppliedID = reaction.id

        if reaction.emotion == .talk {
            pendingJournalRequest = true
            return
        }

        currentReaction = reaction
    }

    func requestJournal() {
        pendingJournalRequest = true
    }

    func clearJournalRequest() {
        pendingJournalRequest = false
    }
}
