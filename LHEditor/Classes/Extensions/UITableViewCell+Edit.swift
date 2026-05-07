import UIKit

extension UITableViewCell {
    func containerTableView() -> UITableView? {
        var v: UIView? = superview
        while v != nil {
            if let tv = v as? UITableView { return tv }
            v = v?.superview
        }
        return nil
    }
}
