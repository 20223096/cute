import SwiftUI

// MARK: - Design sheet (1024×819) layout helpers
// 좌표는 0…1 정규화. 실제 시트와 어긋나면 이 값만 미세 조정하면 됩니다.

enum HealyArt {
    static let sheetAssetName = "healy_design_sheet"
    static let sheetW: CGFloat = 1024
    static let sheetH: CGFloat = 819

    /// 하단 5컷 (힘들어 / 쉬고 싶어 / 짜증 / 나도 소중해 / 걱정)
    static func bottomSceneRect(index: Int) -> CGRect {
        let count = 5
        let w = 1 / CGFloat(count)
        let y: CGFloat = 0.52
        let h: CGFloat = 0.44
        return CGRect(x: w * CGFloat(min(max(index, 0), count - 1)), y: y, width: w, height: h)
    }

    /// 짜증 씬: 체육관 벽·바닥 위주(왼쪽 크롭) — 샌드백은 SwiftUI 레이어로 따로 둠
    static var annoyedGymBackgroundRect: CGRect {
        let cell = bottomSceneRect(index: 2)
        return CGRect(x: cell.minX, y: cell.minY, width: cell.width * 0.5, height: cell.height)
    }
}

enum HealyExpression: Int, CaseIterable {
    case joy, comfort, surprise, sadness, anger, exhaustion, gratitude, love

    var normalizedRect: CGRect {
        let marginX: CGFloat = 0.05
        let colW = (1 - marginX * 2) / 4
        let rowH: CGFloat = 0.125
        let row0Y: CGFloat = 0.165
        let gap: CGFloat = 0.018
        let row1Y = row0Y + rowH + gap
        let idx = rawValue
        let row = idx / 4
        let col = idx % 4
        let y = row == 0 ? row0Y : row1Y
        return CGRect(x: marginX + CGFloat(col) * colW, y: y, width: colW, height: rowH)
    }
}

struct HealyCropView: View {
    var imageName: String = HealyArt.sheetAssetName
    var sheetPixelWidth: CGFloat = HealyArt.sheetW
    var sheetPixelHeight: CGFloat = HealyArt.sheetH
    let normalizedRect: CGRect
    let outW: CGFloat
    let outH: CGFloat

    var body: some View {
        let nx = normalizedRect.minX
        let ny = normalizedRect.minY
        let nw = normalizedRect.width
        let nh = normalizedRect.height
        let W = sheetPixelWidth
        let H = sheetPixelHeight
        let sx = max(outW / (nw * W), outH / (nh * H))
        Image(imageName, bundle: .main)
            .resizable()
            .interpolation(.high)
            .frame(width: W * sx, height: H * sx)
            .offset(x: -nx * W * sx, y: -ny * H * sx)
            .frame(width: outW, height: outH)
            .clipped()
    }
}

struct HealyAvatarView: View {
    var emotion: EmotionType?
    var size: CGFloat = 48

    private var expression: HealyExpression {
        switch emotion ?? .talk {
        case .tired: return .sadness
        case .rest: return .exhaustion
        case .annoyed: return .anger
        case .numb: return .gratitude
        case .worthless: return .love
        case .talk: return .comfort
        }
    }

    var body: some View {
        HealyCropView(normalizedRect: expression.normalizedRect, outW: size, outH: size)
    }
}

extension EmotionType {
    /// 애니메이션 모드 하단 시트 컷 인덱스 (0…4)
    var healyBottomSceneIndex: Int {
        switch self {
        case .tired: return 0
        case .rest: return 1
        case .annoyed: return 2
        case .numb: return 3
        case .worthless: return 4
        case .talk: return 1
        }
    }
}
