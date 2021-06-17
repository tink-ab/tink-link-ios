import UIKit

final class LoadingViewController: UIViewController {
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        let baseColor = (navigationController?.isNavigationBarHidden ?? true) ? Color.background : Color.navigationBarBackground
        if #available(iOS 13.0, *) {
            return baseColor.resolvedColor(with: traitCollection).isLight ? .darkContent : .lightContent
        } else {
            return baseColor.isLight ? .default : .lightContent
        }
    }

    private(set) var onCancel: (() -> Void)?

    private let activityIndicatorView = ActivityIndicatorView()
    private let label = UILabel()
    private let cancelButton = UIButton(type: .system)

    var text: String { label.text ?? "" }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.background
        activityIndicatorView.tintColor = Color.accent
        activityIndicatorView.style = .large
        activityIndicatorView.startAnimating()

        cancelButton.setTitleColor(Color.button, for: .normal)
        cancelButton.titleLabel?.font = Font.subtitle1
        cancelButton.titleLabel?.adjustsFontForContentSizeCategory = true
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        cancelButton.setTitle(Strings.Generic.cancel, for: .normal)

        label.font = Font.subtitle1
        label.textColor = Color.label
        label.numberOfLines = 0
        label.textAlignment = .center

        label.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(label)
        view.addSubview(activityIndicatorView)

        view.addSubview(cancelButton)
        view.addSubview(activityIndicatorView)

        NSLayoutConstraint.activate([
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -36),
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicatorView.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -24),

            label.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -24),

            cancelButton.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -32)
        ])
    }

    func update(_ text: String?, onCancel: (() -> Void)?) {
        dispatchPrecondition(condition: .onQueue(.main))
        if let onCancel = onCancel {
            self.onCancel = onCancel
            cancelButton.isHidden = false
        } else {
            cancelButton.isHidden = true
        }

        label.text = text
    }

    @objc private func cancel() {
        onCancel?()
    }
}
