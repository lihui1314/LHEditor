import UIKit

public final class LHImageEditModel: LHEditModelProtocol {
    public var imageUrl: String?
    public var image: UIImage?
    public var cellHeight: CGFloat = 0
    public var path: IndexPath = IndexPath(row: 0, section: 0)
    public var cellReuseIdentifier: String { "LHImageEditCell" }

    private var _imageAttriStr: NSMutableAttributedString?

    public var imageAttriStr: NSMutableAttributedString {
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

    public init() {}

    public func applyPath(_ path: IndexPath) {
        self.path = path
    }
}
