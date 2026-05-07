import UIKit

final class EditToolConfig {
    static let shared = EditToolConfig()
    var lineSpacing: CGFloat = 0
    var titleFontSize: CGFloat = 20
    var textFontSize: CGFloat = 17
    /// 是否在编辑器顶部显示标题行。需在装载页面前设置（例如在子类 `viewDidLoad` 里调用 `super.viewDidLoad()` 之前）。
    var showsTitle: Bool = true
    private init() {}
}
