import UIKit

final class CredentialsSuccessfullyAddedTransition: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from)!
        let toVC = transitionContext.viewController(forKey: .to)!

        fromVC.navigationController?.setNavigationBarHidden(true, animated: transitionContext.isAnimated)

        transitionContext.containerView.addSubview(toVC.view)

        let duration = transitionDuration(using: transitionContext)

        guard transitionContext.isAnimated else {
            transitionContext.completeTransition(true)
            return
        }

        let toViewBackgroundColor = toVC.view.backgroundColor
        toVC.view.backgroundColor = .clear
        toVC.view.alpha = 0
        let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1.0) {
            for subview in fromVC.view.subviews {
                if subview is ActivityIndicatorView { continue }
                subview.alpha = 0
            }

            toVC.view.alpha = 1
        }

        animator.addCompletion { (position) in
            for subview in fromVC.view.subviews {
                if subview is ActivityIndicatorView { continue }
                subview.alpha = 1
            }
            toVC.view.backgroundColor = toViewBackgroundColor
            transitionContext.completeTransition(position == .end)
        }

        animator.startAnimation()
    }
}
