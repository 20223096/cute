import Foundation

enum LetterDirection: String, Codable, Hashable {
    case incoming
    case outgoing
}

struct EmotionLetter: Identifiable, Codable, Hashable {
    let id: UUID
    var direction: LetterDirection
    var senderName: String
    var senderCharacterID: String
    var recipientID: String
    var recipientName: String
    var emotion: EmotionType
    var mood: VariantMood
    var variantID: String?
    var message: String
    var sentAt: Date
    var openedAt: Date?
    var reply: String?

    init(
        id: UUID = UUID(),
        direction: LetterDirection,
        senderName: String,
        senderCharacterID: String,
        recipientID: String,
        recipientName: String,
        emotion: EmotionType,
        mood: VariantMood,
        variantID: String? = nil,
        message: String,
        sentAt: Date = Date(),
        openedAt: Date? = nil,
        reply: String? = nil
    ) {
        self.id = id
        self.direction = direction
        self.senderName = senderName
        self.senderCharacterID = senderCharacterID
        self.recipientID = recipientID
        self.recipientName = recipientName
        self.emotion = emotion
        self.mood = mood
        self.variantID = variantID
        self.message = message
        self.sentAt = sentAt
        self.openedAt = openedAt
        self.reply = reply
    }

    var isUnopened: Bool { openedAt == nil && direction == .incoming }
}
