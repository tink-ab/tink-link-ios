import UIKit

final class AddCredentialsStatusPresentationController: UIPresentationController {
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

    private let presentedViewWidth: CGFloat = 270

    override var frameOfPresentedViewInContainerView: CGRect {
        let bounds = containerView?.bounds ?? UIScreen.main.bounds

        let presentedViewSize = presentedViewController.view.systemLayoutSizeFitting(CGSize(width: presentedViewWidth, height: bounds.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)

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

    private func show() {
        presentingViewController.view.tintAdjustmentMode = .dimmed
        shadowLayer.opacity = 1
        visualEffectView.alpha = 1
    }

    private func hide() {
        presentingViewController.view.tintAdjustmentMode = .automatic
        shadowLayer.opacity = 0
        visualEffectView.alpha = 0
    }

    override func presentationTransitionWillBegin() {
        containerView?.layer.addSublayer(shadowLayer)
        containerView?.addSubview(visualEffectView)

        shadowLayer.opacity = 0
        visualEffectView.alpha = 0

        visualEffectView.contentView.addSubview(presentedViewController.view)

        if let transitionCoordinator = presentingViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: { _ in
                self.show()
            })
        } else {
            show()
        }
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            shadowLayer.removeFromSuperlayer()
            visualEffectView.removeFromSuperview()
        }
    }

    override func dismissalTransitionWillBegin() {

        if let transitionCoordinator = presentingViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: { _ in
                self.hide()
            })
        } else {
            hide()
        }
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
