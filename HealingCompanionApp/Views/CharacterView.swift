import SwiftUI

#if canImport(UIKit)

struct CharacterView: View {
    let reaction: CompanionReaction
    let motion: MotionStyle
    let size: CGFloat

    init(reaction: CompanionReaction, motion: MotionStyle = .minimal, size: CGFloat = 72) {
        self.reaction = reaction
        self.motion = motion
        self.size = size
    }

    var body: some View {
        HomeCharacterPortraitView(reaction: reaction, motion: motion, size: size)
    }
}

#endif
