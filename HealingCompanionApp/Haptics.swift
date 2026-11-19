import SwiftUI
#if canImport(UIKit)
import AudioToolbox
import UIKit
#endif

enum Haptics {
    static func play(_ style: HapticStyle) {
        #if canImport(UIKit)
        switch style {
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .soft:
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        case .rigid:
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        case .none:
            break
        }
        #endif
    }

    /// 샌드백 펀치: **강한 중후형 진동** + 짧은 이중 임팩트(사용자 입력 시)
    static func playPunchImpact(userDriven: Bool) {
        #if canImport(UIKit)
        if userDriven {
            let heavy = UIImpactFeedbackGenerator(style: .heavy)
            heavy.prepare()
            heavy.impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            }
        } else {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        }
        #endif
    }

    /// 짧은 "툭/퍽" 느낌 (시스템 Tock; 기기 **무음**이면 재생되지 않을 수 있음)
    static func playPunchTock() {
        #if canImport(UIKit)
        AudioServicesPlaySystemSound(1104)
        #endif
    }
}
