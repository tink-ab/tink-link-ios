import UIKit

final class AddCredentialStatusPresentationController: UIPresentationController {
    private lazy var shadowLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor(white: 0.0, alpha: 0.25).cgColor
        shapeLayer.fillRule = .evenOdd
        return shapeLayer
    }()
    private lazy var visualEffectView: UIVisualEffectView = {
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        visualEffectView.layer.cornerRadius = 10
        visualEffectView.clipsToBounds = true
        return visualEffectView
    }()

    private var calculatedFrameOfPresentedViewInContainerView = CGRect.zero
    private var shouldSetFrameWhenAccessingPresentedView = false

    override var frameOfPresentedViewInContainerView: CGRect {
        let bounds = containerView?.bounds ?? UIScreen.main.bounds

        let presentedViewSize = presentedViewController.view.systemLayoutSizeFitting(bounds.size)

        return CGRect(
            origin: .init(
                x: (bounds.width - presentedViewSize.width) / 2,
                y: (bounds.height - presentedViewSize.height) / 2
            ),
            size: presentedViewSize
        )
    }

    override func presentationTransitionWillBegin() {
        presentedViewController.view.frame = frameOfPresentedViewInContainerView

        shadowLayer.frame = containerView?.bounds ?? UIScreen.main.bounds
        let path = UIBezierPath(rect: containerView?.bounds ?? UIScreen.main.bounds)
        path.append(UIBezierPath(roundedRect: visualEffectView.frame, cornerRadius: visualEffectView.layer.cornerRadius))
        shadowLayer.path = path.cgPath

        visualEffectView.frame = frameOfPresentedViewInContainerView

        containerView?.layer.addSublayer(shadowLayer)
        containerView?.addSubview(visualEffectView)

        shadowLayer.opacity = 0
        visualEffectView.alpha = 0
        presentedView?.alpha = 0

        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.presentingViewController.view.tintAdjustmentMode = .dimmed
            self.shadowLayer.opacity = 1
            self.visualEffectView.alpha = 1
            self.presentedView?.alpha = 1
        })
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            shadowLayer.removeFromSuperlayer()
            visualEffectView.removeFromSuperview()
        }

        shouldSetFrameWhenAccessingPresentedView = completed
    }

    override func dismissalTransitionWillBegin() {
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.presentingViewController.view.tintAdjustmentMode = .automatic
            self.shadowLayer.opacity = 0
            self.visualEffectView.alpha = 0
            self.presentedView?.alpha = 0
        })

        shouldSetFrameWhenAccessingPresentedView = false
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            shadowLayer.removeFromSuperlayer()
            visualEffectView.removeFromSuperview()
        }

        presentedViewController.view.frame = frameOfPresentedViewInContainerView
        visualEffectView.frame = frameOfPresentedViewInContainerView
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()

        shadowLayer.frame = containerView?.bounds ?? .zero
        let path = UIBezierPath(rect: containerView?.bounds ?? UIScreen.main.bounds)
        path.append(UIBezierPath(roundedRect: visualEffectView.frame, cornerRadius: visualEffectView.layer.cornerRadius))
        shadowLayer.path = path.cgPath

        visualEffectView.frame = frameOfPresentedViewInContainerView
        presentedView?.frame = frameOfPresentedViewInContainerView
        calculatedFrameOfPresentedViewInContainerView = frameOfPresentedViewInContainerView
    }

    override var presentedView: UIView? {
        if shouldSetFrameWhenAccessingPresentedView {
            super.presentedView?.frame = calculatedFrameOfPresentedViewInContainerView
        }
        return super.presentedView
    }
}
