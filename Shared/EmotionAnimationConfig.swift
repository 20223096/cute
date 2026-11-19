import SwiftUI

enum MotionStyle: String, Codable {
    case slowDroop
    case slowFade
    case fastShake
    case minimal
    case leanBounce
}

enum ParticleStyle: String, Codable {
    case softDots
    case zzz
    case sharpBurst
    case none
    case softBubbles
}

enum HapticStyle: String, Codable {
    case light
    case medium
    case soft
    case rigid
    case none
}

struct EmotionAnimation {
    let primaryColor: Color
    let secondaryColor: Color
    let motion: MotionStyle
    let particleStyle: ParticleStyle
    let hapticStyle: HapticStyle
}

extension EmotionType {
    var animation: EmotionAnimation {
        switch self {
        case .tired:
            return EmotionAnimation(
                primaryColor: Color(red: 1.00, green: 0.87, blue: 0.89),
                secondaryColor: Color(red: 1.00, green: 0.94, blue: 0.88),
                motion: .slowDroop,
                particleStyle: .softDots,
                hapticStyle: .soft
            )
        case .rest:
            return EmotionAnimation(
                primaryColor: Color(red: 0.70, green: 0.73, blue: 0.95),
                secondaryColor: Color(red: 0.85, green: 0.80, blue: 1.00),
                motion: .slowFade,
                particleStyle: .zzz,
                hapticStyle: .light
            )
        case .annoyed:
            return EmotionAnimation(
                primaryColor: Color(red: 1.00, green: 0.72, blue: 0.72),
                secondaryColor: Color(red: 1.00, green: 0.82, blue: 0.60),
                motion: .fastShake,
                particleStyle: .sharpBurst,
                hapticStyle: .rigid
            )
        case .numb:
            return EmotionAnimation(
                primaryColor: Color(red: 0.88, green: 0.88, blue: 0.88),
                secondaryColor: Color(red: 0.95, green: 0.95, blue: 0.97),
                motion: .minimal,
                particleStyle: .none,
                hapticStyle: .none
            )
        case .worthless:
            return EmotionAnimation(
                primaryColor: Color(red: 1.00, green: 0.93, blue: 0.74),
                secondaryColor: Color(red: 0.87, green: 0.96, blue: 0.86),
                motion: .slowFade,
                particleStyle: .softDots,
                hapticStyle: .soft
            )
        case .talk:
            return EmotionAnimation(
                primaryColor: Color(red: 1.00, green: 0.84, blue: 0.75),
                secondaryColor: Color(red: 0.95, green: 0.90, blue: 1.00),
                motion: .leanBounce,
                particleStyle: .softBubbles,
                hapticStyle: .medium
            )
        }
    }
}
