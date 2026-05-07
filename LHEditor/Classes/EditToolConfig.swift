import UIKit

public final class EditToolConfig {
    public static let shared = EditToolConfig()
    public var lineSpacing: CGFloat = 0
    public var titleFontSize: CGFloat = 20
    public var textFontSize: CGFloat = 17
    /// 是否在编辑器顶部显示标题行。需在装载页面前设置（例如在子类 `viewDidLoad` 里调用 `super.viewDidLoad()` 之前）。
    public var showsTitle: Bool = true
    private init() {}
}
