import UIKit

final class LHContentEditModel: LHEditModelProtocol {
    var text: String = ""
    var cellHeight: CGFloat
    var path: IndexPath = IndexPath(row: 0, section: 0)
    var cellReuseIdentifier: String { "LHContentEditeCell" }

    init() {
        let emptyH = "".lhTextViewHeight()
        let phH = "请输入内容".lhTextViewHeight()
        cellHeight = max(emptyH, phH)
    }

    func applyPath(_ path: IndexPath) {
        self.path = path
    }
}
