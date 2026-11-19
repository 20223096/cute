import SwiftUI

struct AnimationSceneView: View {
    let emotion: EmotionType
    let character: CompanionCharacter
    let message: String
    var mood: VariantMood = .active
    var customText: String? = nil
    let onComplete: () -> Void

    var body: some View {
        switch emotion {
        case .tired:
            ComfortTissueSceneView(
                character: character,
                message: message,
                mood: mood,
                customText: customText,
                onComplete: onComplete
            )
        case .rest:
            RestScene(
                character: character,
                message: message,
                mood: mood,
                customText: customText,
                onComplete: onComplete
            )
        case .annoyed:
            AnnoyedScene(
                character: character,
                message: message,
                mood: mood,
                customText: customText,
                onComplete: onComplete
            )
        case .numb:
            NumbScene(
                character: character,
                message: message,
                mood: mood,
                customText: customText,
                onComplete: onComplete
            )
        case .worthless:
            WorthlessScene(
                character: character,
                message: message,
                mood: mood,
                customText: customText,
                onComplete: onComplete
            )
        case .talk:
            TalkScene(
                character: character,
                message: message,
                mood: mood,
                customText: customText,
                onComplete: onComplete
            )
        }
    }
}
