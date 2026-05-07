import UIKit

public final class LHTitleEditModel: LHEditModelProtocol {
    public var text: String?
    public var cellHeight: CGFloat
    public var cellReuseIdentifier: String { "LHTitleEditeCell" }

    public init() {
        let emptyH = "".lhTitleTextViewHeight()
        let phH = "请输入标题".lhTitleTextViewHeight()
        cellHeight = max(emptyH, phH)
    }

    public func applyPath(_ path: IndexPath) {}
}
