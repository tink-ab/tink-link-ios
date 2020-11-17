import UIKit

final class CredentialsSuccessfullyAddedTransition: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from)!
        let toVC = transitionContext.viewController(forKey: .to)!

        transitionContext.containerView.addSubview(toVC.view)

        let duration = transitionDuration(using: transitionContext)

        toVC.view.alpha = 0
        let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1.0) {
            fromVC.view.alpha = 0
            toVC.view.alpha = 1
        }

        animator.addCompletion { (position) in
            transitionContext.completeTransition(position == .end)
        }

        animator.startAnimation()
    }
}
