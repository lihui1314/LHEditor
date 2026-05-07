import UIKit

protocol LHEditModelProtocol: AnyObject {
    var cellHeight: CGFloat { get set }
    var cellReuseIdentifier: String { get }
    func applyPath(_ path: IndexPath)
}

extension LHEditModelProtocol {
    func applyPath(_ path: IndexPath) {}
}

protocol LHEditCellProtocol: AnyObject {
    func configure(model: LHEditModelProtocol, indexPath: IndexPath, delegate: LHEditCellDelegate?)
}

protocol LHEditCellEditing: LHEditCellProtocol {
    func beginEditing(preOne: Bool, location: Int)
}

extension LHEditCellEditing {
    func beginEditing(preOne: Bool, location: Int) {}
}

protocol LHEditCellTextSeparating: LHEditCellProtocol {
    func separateText() -> [Any]
}

extension LHEditCellTextSeparating {
    func separateText() -> [Any] { [] }
}

@objc protocol LHEditCellDelegate: AnyObject {
    func editShouldBeginEditing(at path: IndexPath)
    @objc optional func editImageDelete(at path: IndexPath)
    @objc optional func editImageMoveCursor(from path: IndexPath, text: String)
    @objc optional func editTextCellDelete(at path: IndexPath, textView: UITextView)
}
