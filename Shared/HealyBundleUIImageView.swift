import SwiftUI

#if canImport(UIKit)
import UIKit

/// 번들 PNG를 `UIImageView`로 그려 SwiftUI `Image` 업샘플링보다 깔끔하게 보이게 합니다.
struct HealyBundleUIImageView: UIViewRepresentable {
    let name: String
    var contentMode: UIView.ContentMode = .scaleAspectFill

    func makeUIView(context: Context) -> UIImageView {
        let iv = UIImageView()
        iv.contentMode = contentMode
        iv.clipsToBounds = true
        iv.backgroundColor = .clear
        iv.layer.minificationFilter = .trilinear
        iv.layer.magnificationFilter = .linear
        return iv
    }

    func updateUIView(_ imageView: UIImageView, context: Context) {
        imageView.image = UIImage(named: name, in: Bundle.main, compatibleWith: nil)
    }
}

#endif
