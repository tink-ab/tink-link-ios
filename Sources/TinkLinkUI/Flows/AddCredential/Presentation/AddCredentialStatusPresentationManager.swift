import UIKit

final class AddCredentialStatusPresentationManager: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return AddCredentialStatusPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
