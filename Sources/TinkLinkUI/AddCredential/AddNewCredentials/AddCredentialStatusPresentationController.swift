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

    override var frameOfPresentedViewInContainerView: CGRect {
        let bounds = containerView?.bounds ?? UIScreen.main.bounds

        let presentedViewSize = presentedViewController.view.systemLayoutSizeFitting(CGSize(width: 270, height: bounds.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)

        return CGRect(
            origin: .init(
                x: (bounds.width - presentedViewSize.width) / 2,
                y: (bounds.height - presentedViewSize.height) / 2
            ),
            size: presentedViewSize
        )
    }


    override var presentedView: UIView? {
        return visualEffectView
    }

    override func presentationTransitionWillBegin() {
        containerView?.layer.addSublayer(shadowLayer)
        containerView?.addSubview(visualEffectView)

        shadowLayer.opacity = 0
        visualEffectView.alpha = 0

        visualEffectView.contentView.addSubview(presentedViewController.view)

        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.presentingViewController.view.tintAdjustmentMode = .dimmed
            self.shadowLayer.opacity = 1
            self.visualEffectView.alpha = 1
        })
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            shadowLayer.removeFromSuperlayer()
            visualEffectView.removeFromSuperview()
        }
    }

    override func dismissalTransitionWillBegin() {
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.presentingViewController.view.tintAdjustmentMode = .automatic
            self.shadowLayer.opacity = 0
            self.visualEffectView.alpha = 0
        })
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            shadowLayer.removeFromSuperlayer()
            visualEffectView.removeFromSuperview()
        }
    }

    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()

        let contentFrame = frameOfPresentedViewInContainerView

        shadowLayer.frame = containerView?.bounds ?? .zero
        let path = UIBezierPath(rect: shadowLayer.frame)
        path.append(UIBezierPath(roundedRect: contentFrame, cornerRadius: visualEffectView.layer.cornerRadius))
        shadowLayer.path = path.cgPath

        visualEffectView.frame = contentFrame
        presentedViewController.view.frame = CGRect(origin: .zero, size: contentFrame.size)
    }
}
