import UIKit

final class CredentialsSuccessfullyAddedTransition: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from)!
        let toVC = transitionContext.viewController(forKey: .to) as! CredentialsSuccessfullyAddedViewController

        fromVC.navigationController?.setNavigationBarHidden(true, animated: transitionContext.isAnimated)

        transitionContext.containerView.addSubview(toVC.view)

        let duration = transitionDuration(using: transitionContext)

        guard transitionContext.isAnimated else {
            transitionContext.completeTransition(true)
            return
        }

        let toViewBackgroundColor = toVC.view.backgroundColor
        toVC.view.backgroundColor = .clear
        for subview in toVC.view.subviews {
            if subview is CheckmarkView { continue }
            subview.alpha = 0
        }
        let animator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
            for subview in fromVC.view.subviews {
                if subview is ActivityIndicatorView { continue }
                subview.alpha = 0
            }

            for subview in toVC.view.subviews {
                if subview is CheckmarkView { continue }
                subview.alpha = 1
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration * 0.5) {
            toVC.iconView.setChecked(true, animated: true)
        }

        animator.addCompletion { position in
            for subview in fromVC.view.subviews {
                if subview is ActivityIndicatorView { continue }
                subview.alpha = 1
            }
            fromVC.view.removeFromSuperview()
            toVC.view.backgroundColor = toViewBackgroundColor
            transitionContext.completeTransition(position == .end)
        }

        animator.startAnimation()
    }
}
