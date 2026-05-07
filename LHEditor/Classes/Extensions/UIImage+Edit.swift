import UIKit

extension UIImage {
    func lhScaledForEdit() -> UIImage {
        if size.width > 1080 {
            let scale: CGFloat = 4
            let newSize = CGSize(width: size.width / scale, height: size.height / scale)
            UIGraphicsBeginImageContext(newSize)
            draw(in: CGRect(origin: .zero, size: newSize))
            let img = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return img ?? self
        }
        return self
    }
}
