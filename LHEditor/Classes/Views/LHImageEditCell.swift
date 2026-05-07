import UIKit

final class LHImageEditCell: UITableViewCell, LHEditCellProtocol, LHEditCellEditing, LHEditCellTextSeparating, UITextViewDelegate {
    private lazy var imageTextV: LHTextView = {
        let v = LHTextView()
        v.delegate = self
        v.font = .systemFont(ofSize: 17)
        v.isScrollEnabled = false
        if #available(iOS 16.0, *) {
            v.isFindInteractionEnabled = false
        }
        v.textContainerInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        v.allowsEditingTextAttributes = true
        return v
    }()

    private lazy var imV: UIImageView = UIImageView()

    weak var cellDelegate: LHEditCellDelegate?
    private var path: IndexPath = IndexPath(row: 0, section: 0)
    private var model: LHImageEditModel?
    private var textVHeightConstraint: NSLayoutConstraint!
    private var textVBottomLowPriority: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        imageTextV.translatesAutoresizingMaskIntoConstraints = false
        imV.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageTextV)
        contentView.addSubview(imV)
        textVHeightConstraint = imageTextV.heightAnchor.constraint(equalToConstant: 44)
        textVBottomLowPriority = imageTextV.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        textVBottomLowPriority.priority = UILayoutPriority(900)
        NSLayoutConstraint.activate([
            imageTextV.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageTextV.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageTextV.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            textVHeightConstraint,
            textVBottomLowPriority,
            imV.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            imV.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            imV.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            imV.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:)") }

    func configure(model: LHEditModelProtocol, indexPath: IndexPath, delegate: LHEditCellDelegate?) {
        guard let m = model as? LHImageEditModel else { return }
        self.model = m
        path = indexPath
        m.applyPath(indexPath)
        cellDelegate = delegate
        imageTextV.attributedText = m.imageAttriStr
        textVHeightConstraint.constant = m.cellHeight
        imV.image = m.image
    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        cellDelegate?.editShouldBeginEditing(at: model?.path ?? path)
        return true
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.isEmpty {
            cellDelegate?.editImageDelete?(at: model?.path ?? path)
            return false
        } else {
            cellDelegate?.editImageMoveCursor?(from: model?.path ?? path, text: text)
            return false
        }
    }

    func beginEditing(preOne: Bool, location: Int) {
        imageTextV.becomeFirstResponder()
    }

    func separateText() -> [Any] {
        [false]
    }
}
