import UIKit

public class LHEditViewController: UIViewController {
    public var insertImageEnabled = true

    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.separatorStyle = .none
        tv.delegate = self
        tv.dataSource = self
        tv.estimatedRowHeight = 0
        tv.estimatedSectionFooterHeight = 0
        tv.estimatedSectionHeaderHeight = 0
        return tv
    }()

    private var dataArray: [LHEditModelProtocol] = []
    private lazy var imagePicker: UIImagePickerController = {
        let p = UIImagePickerController()
        p.delegate = self
        return p
    }()

    private var accessoryView: LHEditAccessoryView?
    private var activeEditingPath: IndexPath?
    private var isDeletingImage = false

    /// 首段正文所在的 table 行下标：有标题时为 1，无标题时为 0。
    private var firstContentRowIndex: Int {
        EditToolConfig.shared.showsTitle ? 1 : 0
    }

    private var tableBottomToSafeArea: NSLayoutConstraint!
    private var accessoryBottomToView: NSLayoutConstraint?

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    public func getDataArray() -> [LHEditModelProtocol] {
        dataArray
    }

    public func setDataArray(_ array: [LHEditModelProtocol]) {
        dataArray = array
    }

    /// 修改 `EditToolConfig` 的背景色属性后调用，用于主题切换等场景。
    public func reapplyBackgroundColorsFromConfig() {
        let cfg = EditToolConfig.shared
        let bg = cfg.editorBackgroundColor
        view.backgroundColor = bg
        tableView.backgroundColor = bg
        accessoryView?.backgroundColor = cfg.accessoryBarBackgroundColor
        tableView.reloadData()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        let bg = EditToolConfig.shared.editorBackgroundColor
        view.backgroundColor = bg
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        loadData()
        configTableView()
        imagePicker.allowsEditing = true
        addAccessoryView()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func loadData() {
        if EditToolConfig.shared.showsTitle {
            dataArray = [LHTitleEditModel(), LHContentEditModel()]
        } else {
            dataArray = [LHContentEditModel()]
        }
    }

    private func configTableView() {
        let bg = EditToolConfig.shared.editorBackgroundColor
        tableView.backgroundColor = bg
        tableView.contentInset = UIEdgeInsets(top: tableView.contentInset.top, left: 0, bottom: 70, right: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        tableBottomToSafeArea = tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        tableBottomToSafeArea.isActive = true
        tableView.register(LHTitleEditCell.self, forCellReuseIdentifier: "LHTitleEditeCell")
        tableView.register(LHContentEditCell.self, forCellReuseIdentifier: "LHContentEditeCell")
        tableView.register(LHImageEditCell.self, forCellReuseIdentifier: "LHImageEditCell")
    }

    private func addAccessoryView() {
        guard insertImageEnabled else { return }
        let acc = LHEditAccessoryView()
        acc.delegate = self
        accessoryView = acc
        acc.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(acc)
        NSLayoutConstraint.activate([
            acc.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            acc.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            acc.heightAnchor.constraint(equalToConstant: 50)
        ])
        accessoryBottomToView = acc.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 50)
        accessoryBottomToView?.isActive = true
        // 键盘未弹出时不展示，避免嵌入 TabBarController 时与系统 Tab 条视觉重叠。
        acc.isHidden = true
    }

    private func ensureAccessory() -> LHEditAccessoryView? {
        if !insertImageEnabled { return nil }
        if accessoryView == nil {
            addAccessoryView()
        }
        return accessoryView
    }

    /// 键盘 frame 转到当前 `view` 坐标系，避免 TabBar / 子 VC 嵌入时仍按整屏高度推算导致附件条与键盘脱节。
    private func keyboardEndFrameInSelfView(_ noti: Notification) -> CGRect? {
        guard let v = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return nil }
        return view.convert(v.cgRectValue, from: UIScreen.main.coordinateSpace)
    }

    @objc private func keyboardWillShow(_ noti: Notification) {
        guard let duration = (noti.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
              let kbInView = keyboardEndFrameInSelfView(noti)
        else { return }

        view.layoutIfNeeded()
        let viewH = view.bounds.height
        guard kbInView.minY < viewH else { return }

        let safeBottomY = viewH - view.safeAreaInsets.bottom
        let rawTableConstant = kbInView.minY - safeBottomY
        let tableConstant = min(0, rawTableConstant)
        let hasAccessory = ensureAccessory() != nil
        if hasAccessory {
            accessoryView?.isHidden = false
        }

        UIView.animate(withDuration: duration) {
            if hasAccessory {
                self.tableView.contentInset = UIEdgeInsets(top: self.tableView.contentInset.top, left: 0, bottom: 70, right: 0)
                self.accessoryBottomToView?.constant = kbInView.minY - viewH
            }
            self.tableBottomToSafeArea.constant = tableConstant
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ noti: Notification) {
        if isDeletingImage { return }
        guard let duration = (noti.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        else { return }

        accessoryView?.isHidden = true

        UIView.animate(withDuration: duration) {
            if self.accessoryView != nil {
                self.tableView.contentInset = UIEdgeInsets(top: self.tableView.contentInset.top, left: 0, bottom: 50, right: 0)
                self.accessoryBottomToView?.constant = 50
            }
            self.tableBottomToSafeArea.constant = 0
            self.view.layoutIfNeeded()
        }
    }

    private func insertTextCell(path: IndexPath, text: String) {
        let model = LHContentEditModel()
        model.applyPath(path)
        model.text = text
        dataArray.insert(model, at: path.row)
        tableView.performBatchUpdates {
            tableView.insertRows(at: [path], with: .top)
        }
        tableView.scrollToRow(at: path, at: .bottom, animated: false)
        if let cell = tableView.cellForRow(at: path) as? LHContentEditCell {
            if !text.isEmpty {
                cell.notifyTextChangedFromImageCell()
            }
            cell.notifyTextChangedFromImageCell()
            cell.beginEditing(preOne: false, location: text.count)
        }
    }

    private func insertImageInLastLoc(_ model: LHImageEditModel) {
        guard let ap = activeEditingPath else { return }
        let minRowsWhenEditingLast = EditToolConfig.shared.showsTitle ? 2 : 1
        if ap.row == dataArray.count - 1, dataArray.count >= minRowsWhenEditingLast {
            let contentModel = LHContentEditModel()
            dataArray.insert(model, at: ap.row + 1)
            dataArray.insert(contentModel, at: ap.row + 2)
        } else {
            dataArray.insert(model, at: ap.row + 1)
        }
    }

    private func addImageModel(_ model: LHImageEditModel) {
        guard let ap = activeEditingPath else { return }
        var signPath: IndexPath?
        let mod = dataArray[ap.row]

        if mod is LHImageEditModel {
            insertImageInLastLoc(model)
            signPath = IndexPath(row: ap.row + 2, section: 0)
        } else {
            guard let cell = tableView.cellForRow(at: ap) as? LHEditCellTextSeparating else { return }
            let arr = cell.separateText()
            if arr.count == 1, let insertPre = arr.first as? Bool {
                if insertPre {
                    dataArray.insert(model, at: ap.row)
                    signPath = IndexPath(row: ap.row + 1, section: 0)
                } else {
                    insertImageInLastLoc(model)
                    signPath = IndexPath(row: ap.row + 2, section: 0)
                }
            } else if arr.count > 1 {
                dataArray.remove(at: ap.row)
                if ap.row >= firstContentRowIndex {
                    let preModelO = dataArray[ap.row - 1]
                    if let newPreModel = preModelO as? LHContentEditModel {
                        let a0 = arr[0] as? String ?? ""
                        let a1 = arr.count > 1 ? (arr[1] as? String ?? "") : ""
                        let newT = newPreModel.text + a0
                        newPreModel.text = newT
                        newPreModel.cellHeight = newT.lhTextViewHeight()
                        dataArray.insert(model, at: ap.row)
                        let modelBot = LHContentEditModel()
                        modelBot.text = a1
                        modelBot.cellHeight = a1.lhTextViewHeight()
                        dataArray.insert(modelBot, at: ap.row + 1)
                        signPath = IndexPath(row: ap.row + 1, section: 0)
                    } else {
                        let a0 = arr[0] as? String ?? ""
                        let a1 = arr.count > 1 ? (arr[1] as? String ?? "") : ""
                        let modelTop = LHContentEditModel()
                        modelTop.text = a0
                        modelTop.cellHeight = a0.lhTextViewHeight()
                        let modelBot = LHContentEditModel()
                        modelBot.text = a1
                        modelBot.cellHeight = a1.lhTextViewHeight()
                        dataArray.insert(modelTop, at: ap.row)
                        dataArray.insert(model, at: ap.row + 1)
                        dataArray.insert(modelBot, at: ap.row + 2)
                        signPath = IndexPath(row: ap.row + 2, section: 0)
                    }
                } else {
                    signPath = ap
                }
            }
        }

        guard let sp = signPath else { return }
        tableView.reloadData()
        tableView.scrollToRow(at: sp, at: .bottom, animated: false)
        if let focus = tableView.cellForRow(at: sp) as? LHEditCellEditing {
            DispatchQueue.main.async {
                focus.beginEditing(preOne: false, location: 0)
            }
        }
    }

    private func pickImage() {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true)
    }
}

extension LHEditViewController: UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int { 1 }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArray.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: model.cellReuseIdentifier, for: indexPath)
        cell.selectionStyle = .none
        if let c = cell as? LHEditCellProtocol {
            c.configure(model: model, indexPath: indexPath, delegate: self)
        }
        return cell
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        dataArray[indexPath.row].cellHeight
    }
}

extension LHEditViewController: LHEditCellDelegate {
    func editShouldBeginEditing(at path: IndexPath) {
        guard let acc = accessoryView else { return }
        if EditToolConfig.shared.showsTitle && path.row == 0 {
            acc.pickImgBtn.isHidden = true
        } else {
            acc.pickImgBtn.isHidden = false
            activeEditingPath = path
        }
    }

    func editImageDelete(at path: IndexPath) {
        isDeletingImage = true
        if path.row > firstContentRowIndex {
            if activeEditingPath?.row == dataArray.count - 1 {
                dataArray.remove(at: path.row)
                tableView.performBatchUpdates {
                    tableView.deleteRows(at: [path], with: .fade)
                }
                let newP = IndexPath(row: path.row - 1, section: 0)
                tableView.scrollToRow(at: newP, at: .bottom, animated: false)
                (tableView.cellForRow(at: newP) as? LHEditCellEditing)?.beginEditing(preOne: true, location: 0)
                isDeletingImage = false
                return
            }
            let prePath = IndexPath(row: path.row - 1, section: 0)
            let nextPath = IndexPath(row: path.row + 1, section: 0)
            let preModel = dataArray[prePath.row]
            let nextModel = dataArray[nextPath.row]
            let preIsContent = preModel is LHContentEditModel
            let nextIsExactContent = type(of: nextModel) === LHContentEditModel.self

            if preIsContent, nextIsExactContent, let pM = preModel as? LHContentEditModel, let nM = nextModel as? LHContentEditModel {
                let newModel = LHContentEditModel()
                let newText = pM.text + "\n" + nM.text
                newModel.text = newText
                newModel.cellHeight = newText.lhTextViewHeight()
                dataArray.remove(at: path.row + 1)
                dataArray.remove(at: path.row)
                dataArray.remove(at: path.row - 1)
                dataArray.insert(newModel, at: path.row - 1)
                tableView.reloadData()
                (tableView.cellForRow(at: prePath) as? LHEditCellEditing)?.beginEditing(preOne: true, location: pM.text.count)
                isDeletingImage = false
            } else {
                dataArray.remove(at: path.row)
                tableView.performBatchUpdates {
                    tableView.deleteRows(at: [path], with: .fade)
                }
                let newP = IndexPath(row: path.row - 1, section: 0)
                tableView.scrollToRow(at: newP, at: .bottom, animated: false)
                (tableView.cellForRow(at: newP) as? LHEditCellEditing)?.beginEditing(preOne: true, location: 0)
                isDeletingImage = false
                for i in newP.row..<dataArray.count {
                    dataArray[i].applyPath(IndexPath(row: i, section: 0))
                }
            }
        } else {
            dataArray.remove(at: path.row)
            tableView.performBatchUpdates {
                tableView.deleteRows(at: [path], with: .fade)
            }
            if dataArray.count == 1 {
                insertTextCell(path: path, text: "")
            } else {
                let cell = tableView.cellForRow(at: path) as? LHEditCellEditing
                let m = dataArray[path.row]
                m.applyPath(path)
                cell?.beginEditing(preOne: false, location: 0)
            }
            isDeletingImage = false
        }
    }

    func editImageMoveCursor(from path: IndexPath, text: String) {
        let newP = IndexPath(row: path.row + 1, section: 0)
        if newP.row < dataArray.count {
            let m = dataArray[newP.row]
            if let cModel = m as? LHContentEditModel {
                tableView.scrollToRow(at: newP, at: .middle, animated: false)
                guard let cell = tableView.cellForRow(at: newP) as? LHContentEditCell else { return }
                var newText = text + cModel.text
                var len: Int
                if newText.count == 1 {
                    newText = ""
                    len = 0
                } else {
                    len = text == "\n" ? 0 : text.count
                }
                cell.contentTextView.text = newText
                cell.notifyTextChangedFromImageCell()
                cell.beginEditing(preOne: false, location: len)
            } else {
                var t = text
                if t == "\n" { t = "" }
                insertTextCell(path: newP, text: t)
                for i in newP.row..<dataArray.count {
                    dataArray[i].applyPath(IndexPath(row: i, section: 0))
                }
            }
        } else {
            var t = text
            if t == "\n" { t = "" }
            insertTextCell(path: newP, text: t)
        }
    }

    func editTextCellDelete(at path: IndexPath, textView: UITextView) {
        guard path.row > firstContentRowIndex else { return }
        if textView.text.isEmpty {
            isDeletingImage = true
            let newP = IndexPath(row: path.row - 1, section: 0)
            let cell = tableView.cellForRow(at: newP) as? LHEditCellEditing
            DispatchQueue.main.async {
                cell?.beginEditing(preOne: true, location: 0)
                self.isDeletingImage = false
            }
            DispatchQueue.main.async {
                self.dataArray.remove(at: path.row)
                self.tableView.performBatchUpdates {
                    self.tableView.deleteRows(at: [path], with: .none)
                }
            }
            for i in newP.row..<dataArray.count {
                dataArray[i].applyPath(IndexPath(row: i, section: 0))
            }
        } else {
            isDeletingImage = true
            let newP = IndexPath(row: path.row - 1, section: 0)
            let cell = tableView.cellForRow(at: newP) as? LHEditCellEditing
            DispatchQueue.main.async {
                cell?.beginEditing(preOne: true, location: 0)
                self.isDeletingImage = false
            }
        }
    }
}

extension LHEditViewController: LHEditAccessoryViewDelegate {
    func editAccessoryView(_ view: LHEditAccessoryView, didTrigger action: LHEditAccessoryAction) {
        switch action {
        case .pickImage:
            pickImage()
        case .dismissKeyboard:
            self.view.endEditing(true)
        }
    }
}

extension LHEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let image = (info[.originalImage] as? UIImage)?.lhScaledForEdit() ?? UIImage()
        let model = LHImageEditModel()
        model.image = image
        let w = UIScreen.main.bounds.width - 20
        model.cellHeight = image.size.height * (w / max(image.size.width, 1)) + 10
        addImageModel(model)
        picker.dismiss(animated: true)
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
