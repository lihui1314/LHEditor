import UIKit

extension String {
    func lhTextViewHeight() -> CGFloat {
        let cfg = EditToolConfig.shared
        let tv = UITextView()
        tv.font = .systemFont(ofSize: cfg.textFontSize)
        tv.isScrollEnabled = false
        tv.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 20, height: 100_000)
        if cfg.lineSpacing != 0 {
            let sty = NSMutableParagraphStyle()
            sty.lineSpacing = cfg.lineSpacing
            tv.typingAttributes = [
                .paragraphStyle: sty,
                .font: UIFont.systemFont(ofSize: cfg.textFontSize),
                .foregroundColor: UIColor.darkGray
            ]
        }
        tv.text = self
        return tv.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 20, height: .greatestFiniteMagnitude)).height
    }

    func lhTitleTextViewHeight() -> CGFloat {
        let cfg = EditToolConfig.shared
        let tv = UITextView()
        tv.font = .systemFont(ofSize: cfg.titleFontSize)
        tv.isScrollEnabled = false
        tv.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 20, height: 10_000)
        if cfg.lineSpacing != 0 {
            let sty = NSMutableParagraphStyle()
            sty.lineSpacing = cfg.lineSpacing
            tv.typingAttributes = [
                .paragraphStyle: sty,
                .font: UIFont.systemFont(ofSize: cfg.titleFontSize),
                .foregroundColor: UIColor.darkGray
            ]
        }
        tv.text = self
        return tv.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 20, height: .greatestFiniteMagnitude)).height
    }
}
