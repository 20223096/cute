import AppIntents
import WidgetKit

enum EmotionAppEnum: String, AppEnum {
    case tired
    case rest
    case annoyed
    case numb
    case worthless
    case talk

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Emotion"
    static var caseDisplayRepresentations: [EmotionAppEnum: DisplayRepresentation] = [
        .tired: "😭",
        .rest: "😴",
        .annoyed: "😡",
        .numb: "😶",
        .worthless: "🥀",
        .talk: "💬"
    ]

    var emotionType: EmotionType {
        EmotionType(rawValue: rawValue) ?? .talk
    }
}

struct SelectEmotionIntent: AppIntent {
    static var title: LocalizedStringResource = "Select Emotion"
    static var description = IntentDescription("Tap an emotion to get a tiny comfort reaction in the widget.")
    // Stay on the home screen so the burst animation + message show in-place.
    static var openAppWhenRun: Bool = false

    @Parameter(title: "Emotion")
    var emotion: EmotionAppEnum

    init() {}

    init(emotion: EmotionAppEnum) {
        self.emotion = emotion
    }

    func perform() async throws -> some IntentResult {
        HealingEngine.saveReaction(for: emotion.emotionType)
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
