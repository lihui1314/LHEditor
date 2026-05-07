import UIKit

public final class EditToolConfig {
    public static let shared = EditToolConfig()
    public var lineSpacing: CGFloat = 0
    public var titleFontSize: CGFloat = 20
    public var textFontSize: CGFloat = 17
    /// 是否在编辑器顶部显示标题行。需在装载页面前设置（例如在子类 `viewDidLoad` 里调用 `super.viewDidLoad()` 之前）。
    public var showsTitle: Bool = true

    /// 编辑器页面与列表底色（`LHEditViewController` 根视图、`UITableView`、单元格 `contentView`）。须在装载 `LHEditViewController` 的视图之前设置。
    public var editorBackgroundColor: UIColor = .white

    /// 标题 / 正文 / 图片旁 `UITextView` 的底色。须在装载编辑器视图之前设置。
    public var textFieldBackgroundColor: UIColor = .white

    /// 底部插图工具条底色。须在装载编辑器视图之前设置。
    public var accessoryBarBackgroundColor: UIColor = .white

    private init() {}
}
