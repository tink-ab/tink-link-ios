import UIKit

extension NSLayoutConstraint {
    func withPriority(_ layoutPriority: UILayoutPriority) -> NSLayoutConstraint {
        priority = layoutPriority
        return self
    }
}
