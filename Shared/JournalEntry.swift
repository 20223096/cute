import Foundation

struct JournalEntry: Identifiable, Codable, Hashable {
    let id: UUID
    var text: String
    var mood: EmotionType?
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        text: String,
        mood: EmotionType? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.text = text
        self.mood = mood
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
