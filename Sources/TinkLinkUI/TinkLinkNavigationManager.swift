import UIKit

final class TinkLinkNavigationManager: NSObject {}

// MARK: - UINavigationControllerDelegate

extension TinkLinkNavigationManager: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch (operation, fromVC, toVC) {
        case (.push, is CredentialsFormViewController, is LoadingViewController):
            return CredentialsFormToLoadingTransition()
        case (.push, _, is CredentialsSuccessfullyAddedViewController):
            return CredentialsSuccessfullyAddedTransition()
        default:
            return nil
        }
    }
}
