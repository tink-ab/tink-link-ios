import UIKit

struct KeyboardNotification {
    let frame: CGRect
    let duration: TimeInterval
    let curve: UIView.AnimationCurve

    fileprivate init?(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let value = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int
        else { return nil }

        self.frame = value.cgRectValue
        self.duration = duration
        self.curve = UIView.AnimationCurve(rawValue: curve) ?? .linear
    }
}

final class KeyboardObserver {
    var willShow: ((KeyboardNotification) -> Void)?
    var willHide: ((KeyboardNotification) -> Void)?

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyboard(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyboard(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willHideKeyboard(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func willShowKeyboard(_ notification: Notification) {
        if let notification = KeyboardNotification(notification: notification) {
            willShow?(notification)
        }
    }

    @objc private func willHideKeyboard(_ notification: Notification) {
        if let notification = KeyboardNotification(notification: notification) {
            willHide?(notification)
        }
    }
}
