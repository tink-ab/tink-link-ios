import UIKit

final class TinkLinkNavigationManager: NSObject {

}

// MARK: - UINavigationControllerDelegate

extension TinkLinkNavigationManager: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push, fromVC is CredentialsFormViewController, toVC is LoadingViewController {
            return CredentialsFormToLoadingTransition()
        } else if operation == .push, fromVC is LoadingViewController, toVC is CredentialsSuccessfullyAddedViewController {
            return CredentialsSuccessfullyAddedTransition()
        } else {
            return nil
        }
    }
}
