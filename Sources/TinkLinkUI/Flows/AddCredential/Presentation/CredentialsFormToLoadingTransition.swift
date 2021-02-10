import UIKit

final class CredentialsFormToLoadingTransition: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from)!
        let toVC = transitionContext.viewController(forKey: .to)!

        fromVC.navigationController?.setNavigationBarHidden(true, animated: transitionContext.isAnimated)

        transitionContext.containerView.addSubview(toVC.view)

        guard transitionContext.isAnimated else {
            transitionContext.completeTransition(true)
            return
        }

        let duration = transitionDuration(using: transitionContext)

        toVC.view.alpha = 0
        let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1.0) {
            toVC.view.alpha = 1
        }

        animator.addCompletion { position in
            transitionContext.completeTransition(position == .end)
        }

        animator.startAnimation()
    }
}
