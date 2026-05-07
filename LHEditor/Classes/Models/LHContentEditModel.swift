import UIKit

public final class LHContentEditModel: LHEditModelProtocol {
    public var text: String = ""
    public var cellHeight: CGFloat
    public var path: IndexPath = IndexPath(row: 0, section: 0)
    public var cellReuseIdentifier: String { "LHContentEditeCell" }

    public init() {
        let emptyH = "".lhTextViewHeight()
        let phH = "请输入内容".lhTextViewHeight()
        cellHeight = max(emptyH, phH)
    }

    public func applyPath(_ path: IndexPath) {
        self.path = path
    }
}
