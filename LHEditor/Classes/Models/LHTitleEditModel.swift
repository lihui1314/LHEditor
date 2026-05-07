import UIKit

final class LHTitleEditModel: LHEditModelProtocol {
    var text: String?
    var cellHeight: CGFloat
    var cellReuseIdentifier: String { "LHTitleEditeCell" }

    init() {
        let emptyH = "".lhTitleTextViewHeight()
        let phH = "请输入标题".lhTitleTextViewHeight()
        cellHeight = max(emptyH, phH)
    }
}
