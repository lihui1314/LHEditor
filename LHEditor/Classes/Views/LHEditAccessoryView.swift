import UIKit

enum LHEditAccessoryAction: Int {
    case pickImage = 0
    case dismissKeyboard = 1
}

protocol LHEditAccessoryViewDelegate: AnyObject {
    func editAccessoryView(_ view: LHEditAccessoryView, didTrigger action: LHEditAccessoryAction)
}

final class LHEditAccessoryView: UIView {
    weak var delegate: LHEditAccessoryViewDelegate?

    private(set) lazy var pickImgBtn: UIButton = {
        let b = UIButton(type: .custom)
        let img = UIImage(systemName: "photo.on.rectangle")
        b.setImage(img, for: .normal)
        b.tintColor = .darkGray
        b.addTarget(self, action: #selector(pickImage), for: .touchUpInside)
        return b
    }()

    private lazy var packUpKeybordBtn: UIButton = {
        let b = UIButton(type: .custom)
        let img = UIImage(systemName: "keyboard.chevron.compact.down")
        b.setImage(img, for: .normal)
        b.tintColor = .darkGray
        b.addTarget(self, action: #selector(packKeyboard), for: .touchUpInside)
        return b
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.cgColor
        pickImgBtn.translatesAutoresizingMaskIntoConstraints = false
        packUpKeybordBtn.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pickImgBtn)
        addSubview(packUpKeybordBtn)
        NSLayoutConstraint.activate([
            pickImgBtn.centerYAnchor.constraint(equalTo: centerYAnchor),
            pickImgBtn.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            pickImgBtn.heightAnchor.constraint(equalToConstant: 30),
            packUpKeybordBtn.centerYAnchor.constraint(equalTo: centerYAnchor),
            packUpKeybordBtn.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            packUpKeybordBtn.widthAnchor.constraint(equalToConstant: 30),
            packUpKeybordBtn.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:)") }

    @objc private func pickImage() {
        delegate?.editAccessoryView(self, didTrigger: .pickImage)
    }

    @objc private func packKeyboard() {
        delegate?.editAccessoryView(self, didTrigger: .dismissKeyboard)
    }
}
