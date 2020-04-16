import UIKit

final class AddCredentialsStatusPresentationManager: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return AddCredentialsStatusPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
