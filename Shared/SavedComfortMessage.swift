import Foundation

struct SavedComfortMessage: Identifiable, Codable, Hashable {
    let id: UUID
    var text: String
    var emotion: EmotionType
    var mood: VariantMood
    var variantID: String?
    let createdAt: Date
    var lastUsedAt: Date?
    var useCount: Int
    var userOverridden: Bool

    init(
        id: UUID = UUID(),
        text: String,
        emotion: EmotionType,
        mood: VariantMood,
        variantID: String? = nil,
        createdAt: Date = Date(),
        lastUsedAt: Date? = nil,
        useCount: Int = 0,
        userOverridden: Bool = false
    ) {
        self.id = id
        self.text = text
        self.emotion = emotion
        self.mood = mood
        self.variantID = variantID
        self.createdAt = createdAt
        self.lastUsedAt = lastUsedAt
        self.useCount = useCount
        self.userOverridden = userOverridden
    }
}
