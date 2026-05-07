import UIKit

private let kContentPlaceholderTag = 87_234

final class LHContentEditCell: UITableViewCell, LHEditCellProtocol, LHEditCellEditing, LHEditCellTextSeparating, UITextViewDelegate {
    private var firstContentRowIndex: Int {
        EditToolConfig.shared.showsTitle ? 1 : 0
    }

    private(set) var contentTextView = LHTextView()
    weak var cellDelegate: LHEditCellDelegate?
    private var path: IndexPath = IndexPath(row: 0, section: 0)
    private var model: LHContentEditModel?
    private var textViewHeightConstraint: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:)") }

    private func setupViews() {
        contentTextView.isScrollEnabled = false
        contentTextView.isEditable = true
        contentTextView.isSelectable = true
        contentTextView.isUserInteractionEnabled = true
        if #available(iOS 16.0, *) {
            contentTextView.isFindInteractionEnabled = false
        }
        let cfg = EditToolConfig.shared
        contentView.backgroundColor = cfg.editorBackgroundColor
        contentTextView.backgroundColor = cfg.textFieldBackgroundColor
        contentTextView.font = .systemFont(ofSize: cfg.textFontSize)
        contentTextView.delegate = self
        if cfg.lineSpacing != 0 {
            let sty = NSMutableParagraphStyle()
            sty.lineSpacing = cfg.lineSpacing
            contentTextView.typingAttributes = [
                .paragraphStyle: sty,
                .font: UIFont.systemFont(ofSize: cfg.textFontSize),
                .foregroundColor: UIColor.darkGray
            ]
        }
        contentTextView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(contentTextView)
        textViewHeightConstraint = contentTextView.heightAnchor.constraint(equalToConstant: 40)
        NSLayoutConstraint.activate([
            contentTextView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            contentTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            textViewHeightConstraint
        ])
    }

    private func setPlaceholder(_ str: String) {
        contentTextView.viewWithTag(kContentPlaceholderTag)?.removeFromSuperview()
        contentTextView.setValue(nil, forKey: "_placeholderLabel")
        guard !str.isEmpty else { return }
        let label = LHLabel()
        label.tag = kContentPlaceholderTag
        label.text = str
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.isUserInteractionEnabled = false
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: EditToolConfig.shared.textFontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        contentTextView.addSubview(label)
        contentTextView.setValue(label, forKey: "_placeholderLabel")
        let inset = contentTextView.textContainerInset
        let pad = contentTextView.textContainer.lineFragmentPadding
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentTextView.leadingAnchor, constant: inset.left + pad),
            label.trailingAnchor.constraint(equalTo: contentTextView.trailingAnchor, constant: -(inset.right + pad)),
            label.topAnchor.constraint(equalTo: contentTextView.topAnchor, constant: inset.top)
        ])
        label.isHidden = !contentTextView.text.isEmpty
    }

    func configure(model: LHEditModelProtocol, indexPath: IndexPath, delegate: LHEditCellDelegate?) {
        guard let m = model as? LHContentEditModel else { return }
        cellDelegate = delegate
        self.model = m
        path = indexPath
        m.applyPath(indexPath)
        contentTextView.text = m.text
        textViewHeightConstraint.constant = m.cellHeight
        if indexPath.row == firstContentRowIndex && contentTextView.text.isEmpty {
            setPlaceholder("请输入内容")
        } else {
            setPlaceholder("")
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        contentTextView.viewWithTag(kContentPlaceholderTag)?.isHidden = !textView.text.isEmpty
        let newSize = textView.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 20, height: .greatestFiniteMagnitude))
        model?.text = textView.text
        model?.cellHeight = newSize.height
        if abs(textViewHeightConstraint.constant - newSize.height) > 5, let tv = containerTableView() {
            tv.performBatchUpdates {
                textViewHeightConstraint.constant = model?.cellHeight ?? newSize.height
            }
            scrollToCursor(textView)
        }
    }

    private func scrollToCursor(_ textView: UITextView) {
        guard let start = textView.selectedTextRange?.start else { return }
        var rect = textView.caretRect(for: start)
        rect.size.height += 15
        guard let table = containerTableView() else { return }
        rect = table.convert(rect, from: textView)
        table.scrollRectToVisible(rect, animated: true)
    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        cellDelegate?.editShouldBeginEditing(at: model?.path ?? path)
        return true
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (model?.path.row ?? 0) == firstContentRowIndex && textView.text.isEmpty {
            setPlaceholder("请输入内容")
        }
        if text.isEmpty {
            if textView.text.isEmpty || textView.selectedRange.location == 0 {
                cellDelegate?.editTextCellDelete?(at: model?.path ?? path, textView: textView)
                return true
            }
        }
        return true
    }

    func separateText() -> [Any] {
        let tv = contentTextView
        if tv.selectedRange.location == 0 { return [true] }
        if tv.selectedRange.location == tv.text.count { return [false] }
        let seletedRange = tv.selectedRange
        var arr: [Any] = []
        if seletedRange.location > 0 {
            let s = String(tv.text.prefix(seletedRange.location))
            arr.append(s)
        }
        if seletedRange.location + seletedRange.length < tv.text.count {
            let start = tv.text.index(tv.text.startIndex, offsetBy: seletedRange.location + seletedRange.length)
            let s = String(tv.text[start...])
            arr.append(s)
        }
        if arr.count > 1, let last = arr[1] as? String, last.first == "\n" {
            arr[1] = String(last.dropFirst())
        }
        return arr
    }

    func beginEditing(preOne: Bool, location: Int) {
        contentTextView.becomeFirstResponder()
        if preOne {
            let len = contentTextView.text.count
            let loc = location == 0 ? len : location
            contentTextView.selectedRange = NSRange(location: loc, length: 0)
        } else {
            contentTextView.selectedRange = NSRange(location: location, length: 0)
        }
    }

    func notifyTextChangedFromImageCell() {
        textViewDidChange(contentTextView)
    }
}
