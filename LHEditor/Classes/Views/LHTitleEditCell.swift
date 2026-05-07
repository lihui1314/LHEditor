import UIKit

private let kTitlePlaceholderTag = 87_233

final class LHTitleEditCell: UITableViewCell, LHEditCellProtocol, LHEditCellEditing, UITextViewDelegate {
    private let titleTextView = LHTextView()
    private let segmentationImv = UIImageView()
    weak var cellDelegate: LHEditCellDelegate?
    private var path: IndexPath = IndexPath(row: 0, section: 0)
    private var model: LHTitleEditModel?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupViews()
        setupPlaceholder()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:)") }

    private func setupViews() {
        titleTextView.isScrollEnabled = false
        titleTextView.isEditable = true
        titleTextView.isSelectable = true
        titleTextView.isUserInteractionEnabled = true
        if #available(iOS 16.0, *) {
            titleTextView.isFindInteractionEnabled = false
        }
        titleTextView.delegate = self
        let cfg = EditToolConfig.shared
        titleTextView.font = .systemFont(ofSize: cfg.titleFontSize)
        titleTextView.textColor = .darkGray
        titleTextView.backgroundColor = .white
        if cfg.lineSpacing != 0 {
            let sty = NSMutableParagraphStyle()
            sty.lineSpacing = cfg.lineSpacing
            titleTextView.typingAttributes = [
                .paragraphStyle: sty,
                .font: UIFont.systemFont(ofSize: cfg.titleFontSize),
                .foregroundColor: UIColor.darkGray
            ]
        }
        segmentationImv.image = Self.dashedLineImage(width: UIScreen.main.bounds.width - 20)
        titleTextView.translatesAutoresizingMaskIntoConstraints = false
        segmentationImv.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleTextView)
        contentView.addSubview(segmentationImv)
        let bottomLo = titleTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        bottomLo.priority = UILayoutPriority(900)
        NSLayoutConstraint.activate([
            titleTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            titleTextView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bottomLo,
            segmentationImv.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            segmentationImv.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            segmentationImv.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1),
            segmentationImv.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    private func setupPlaceholder() {
        titleTextView.viewWithTag(kTitlePlaceholderTag)?.removeFromSuperview()
        let label = UILabel()
        label.tag = kTitlePlaceholderTag
        label.text = "请输入标题"
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.isUserInteractionEnabled = false
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: EditToolConfig.shared.titleFontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        titleTextView.addSubview(label)
        titleTextView.setValue(label, forKey: "_placeholderLabel")
        let inset = titleTextView.textContainerInset
        let pad = titleTextView.textContainer.lineFragmentPadding
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: titleTextView.leadingAnchor, constant: inset.left + pad),
            label.trailingAnchor.constraint(equalTo: titleTextView.trailingAnchor, constant: -(inset.right + pad)),
            label.topAnchor.constraint(equalTo: titleTextView.topAnchor, constant: inset.top)
        ])
        label.isHidden = !(titleTextView.text?.isEmpty ?? true)
    }

    private static func dashedLineImage(width: CGFloat) -> UIImage {
        let size = CGSize(width: width, height: 1)
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        guard let ctx = UIGraphicsGetCurrentContext() else { return UIImage() }
        ctx.setLineCap(.round)
        ctx.setStrokeColor(UIColor(red: 133 / 255, green: 133 / 255, blue: 133 / 255, alpha: 1).cgColor)
        ctx.setLineDash(phase: 0, lengths: [6, 4])
        ctx.move(to: CGPoint(x: 0, y: 1))
        ctx.addLine(to: CGPoint(x: width, y: 1))
        ctx.strokePath()
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }

    func configure(model: LHEditModelProtocol, indexPath: IndexPath, delegate: LHEditCellDelegate?) {
        guard let m = model as? LHTitleEditModel else { return }
        self.model = m
        self.path = indexPath
        cellDelegate = delegate
        titleTextView.text = m.text
        if let ph = titleTextView.viewWithTag(kTitlePlaceholderTag) {
            ph.isHidden = !(m.text?.isEmpty ?? true)
        }
    }

    func beginEditing(preOne: Bool, location: Int) {
        titleTextView.becomeFirstResponder()
        let len = titleTextView.text?.count ?? 0
        if preOne {
            let loc = location == 0 ? len : location
            titleTextView.selectedRange = NSRange(location: loc, length: 0)
        } else {
            titleTextView.selectedRange = NSRange(location: location, length: 0)
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        text == "\n" ? false : true
    }

    func textViewDidChange(_ textView: UITextView) {
        titleTextView.viewWithTag(kTitlePlaceholderTag)?.isHidden = !textView.text.isEmpty
        let newSize = textView.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 20, height: .greatestFiniteMagnitude))
        model?.text = textView.text
        model?.cellHeight = newSize.height
        containerTableView()?.performBatchUpdates(nil)
    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        cellDelegate?.editShouldBeginEditing(at: path)
        return true
    }
}
