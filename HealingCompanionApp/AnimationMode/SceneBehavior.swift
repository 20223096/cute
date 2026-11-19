import Foundation
import CoreGraphics

struct SceneBehavior {
    let mood: VariantMood
    let showBubble: Bool
    let duration: TimeInterval
    let bubbleDelayOffset: TimeInterval

    static func from(_ mood: VariantMood?) -> SceneBehavior {
        let mood = mood ?? .active
        switch mood {
        case .active:
            return SceneBehavior(mood: mood, showBubble: true, duration: 9.0, bubbleDelayOffset: 0)
        case .quiet:
            return SceneBehavior(mood: mood, showBubble: true, duration: 9.5, bubbleDelayOffset: 0.6)
        case .silent:
            return SceneBehavior(mood: mood, showBubble: false, duration: 8.5, bubbleDelayOffset: 0)
        case .ack:
            return SceneBehavior(mood: mood, showBubble: true, duration: 7.0, bubbleDelayOffset: -0.6)
        }
    }
}
