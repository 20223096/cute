import Foundation

struct EmotionEntry: Identifiable, Codable, Hashable {
    var id: UUID
    let date: Date
    let emotion: EmotionType
    let characterID: String
    let message: String
    let note: String?

    init(
        id: UUID = UUID(),
        date: Date,
        emotion: EmotionType,
        characterID: String,
        message: String,
        note: String? = nil
    ) {
        self.id = id
        self.date = date
        self.emotion = emotion
        self.characterID = characterID
        self.message = message
        self.note = note
    }
}

extension EmotionEntry {
    var character: CompanionCharacter {
        HealingCatalog.characters.first(where: { $0.id == characterID })
            ?? HealingCatalog.characters[0]
    }
}
