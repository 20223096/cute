import Foundation
import SwiftUI

@MainActor
final class LetterStore: ObservableObject {
    @Published private(set) var letters: [EmotionLetter] = []

    private let fileURL: URL

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.fileURL = docs.appendingPathComponent("emotion_letters.json")
        load()
        if letters.isEmpty {
            seedMock()
        }
    }

    var inbox: [EmotionLetter] {
        letters.filter { $0.direction == .incoming }.sorted { $0.sentAt > $1.sentAt }
    }

    var sent: [EmotionLetter] {
        letters.filter { $0.direction == .outgoing }.sorted { $0.sentAt > $1.sentAt }
    }

    var unreadCount: Int { inbox.filter { $0.isUnopened }.count }

    func lettersFor(friend: Friend) -> [EmotionLetter] {
        letters
            .filter { ($0.direction == .incoming && $0.senderName == friend.name)
                   || ($0.direction == .outgoing && $0.recipientID == friend.id) }
            .sorted { $0.sentAt > $1.sentAt }
    }

    @discardableResult
    func send(
        to friend: Friend,
        emotion: EmotionType,
        mood: VariantMood,
        variantID: String?,
        message: String,
        senderName: String = "나",
        senderCharacterID: String = HealingCatalog.characters.first?.id ?? "healy"
    ) -> EmotionLetter {
        let letter = EmotionLetter(
            direction: .outgoing,
            senderName: senderName,
            senderCharacterID: senderCharacterID,
            recipientID: friend.id,
            recipientName: friend.name,
            emotion: emotion,
            mood: mood,
            variantID: variantID,
            message: message,
            sentAt: Date(),
            openedAt: Date()
        )
        letters.insert(letter, at: 0)
        persist()
        return letter
    }

    func markOpened(_ letter: EmotionLetter) {
        guard let idx = letters.firstIndex(where: { $0.id == letter.id }) else { return }
        if letters[idx].openedAt == nil {
            letters[idx].openedAt = Date()
            persist()
        }
    }

    func setReply(_ reply: String, on letter: EmotionLetter) {
        guard let idx = letters.firstIndex(where: { $0.id == letter.id }) else { return }
        letters[idx].reply = reply
        persist()
    }

    func delete(_ letter: EmotionLetter) {
        letters.removeAll { $0.id == letter.id }
        persist()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([EmotionLetter].self, from: data)
        else { return }
        letters = decoded.sorted { $0.sentAt > $1.sentAt }
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(letters) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    private func seedMock() {
        let now = Date()
        let cal = Calendar.current
        func hoursAgo(_ h: Int) -> Date { cal.date(byAdding: .hour, value: -h, to: now) ?? now }

        let samples: [EmotionLetter] = [
            EmotionLetter(
                direction: .incoming,
                senderName: "유리",
                senderCharacterID: "healy",
                recipientID: "me",
                recipientName: "나",
                emotion: .tired,
                mood: .active,
                variantID: "tired.active",
                message: "여기, 줄게",
                sentAt: hoursAgo(2)
            ),
            EmotionLetter(
                direction: .incoming,
                senderName: "수민",
                senderCharacterID: "healy",
                recipientID: "me",
                recipientName: "나",
                emotion: .rest,
                mood: .quiet,
                variantID: "rest.quiet",
                message: "아무것도 안 해도 괜찮아",
                sentAt: hoursAgo(22)
            )
        ]
        letters = samples
        persist()
    }
}
