import UIKit

final class LHImageEditModel: LHEditModelProtocol {
    var imageUrl: String?
    var image: UIImage?
    var cellHeight: CGFloat = 0
    var path: IndexPath = IndexPath(row: 0, section: 0)
    var cellReuseIdentifier: String { "LHImageEditCell" }

    private var _imageAttriStr: NSMutableAttributedString?

    var imageAttriStr: NSMutableAttributedString {
        if let s = _imageAttriStr { return s }
        let attachment = NSTextAttachment()
        attachment.image = UIImage()
        attachment.bounds = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: cellHeight)
        let att = NSAttributedString(attachment: attachment)
        let m = NSMutableAttributedString(string: "")
        m.insert(att, at: 0)
        _imageAttriStr = m
        return m
    }

    func applyPath(_ path: IndexPath) {
        self.path = path
    }
}
