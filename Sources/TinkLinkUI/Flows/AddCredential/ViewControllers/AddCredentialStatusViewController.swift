import UIKit

protocol AddCredentialStatusViewControllerDelegate: AnyObject {
    func addCredentialStatusViewControllerDidCancel(_ viewController: AddCredentialStatusViewController)
}

final class AddCredentialStatusViewController: UIViewController {
    private lazy var activityIndicator = ActivityIndicatorView()
    private lazy var statusLabelView = UILabel()
    private lazy var cancelButton = UIButton(type: .system)

    weak var delegate: AddCredentialStatusViewControllerDelegate?

    var status: String? {
        get {
            guard isViewLoaded else { return nil }
            return statusLabelView.text
        }
        set {
            guard isViewLoaded else { return }
            statusLabelView.text = newValue
            presentationController?.containerView?.setNeedsLayout()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let contentStackView = UIStackView(arrangedSubviews: [activityIndicator, statusLabelView])
        contentStackView.axis = .vertical
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(top: 32, left: 24, bottom: 24, right: 24)
        contentStackView.spacing = 16

        let dividerView = UIView()
        dividerView.backgroundColor = Color.separator

        let stackView = UIStackView(arrangedSubviews: [contentStackView, dividerView, cancelButton])
        stackView.axis = .vertical
        stackView.insetsLayoutMarginsFromSafeArea = false
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .zero
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        statusLabelView.font = UIFont.preferredFont(forTextStyle: .headline)
        statusLabelView.numberOfLines = 0
        statusLabelView.preferredMaxLayoutWidth = 220
        statusLabelView.textAlignment = .center

        activityIndicator.tintColor = Color.accent
        activityIndicator.startAnimating()
        activityIndicator.setContentHuggingPriority(.defaultLow, for: .vertical)

        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = Font.semibold(.hecto)
        cancelButton.addTarget(self, action: #selector(close(_:)), for: .touchUpInside)
        cancelButton.setContentHuggingPriority(.defaultLow, for: .horizontal)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dividerView.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale),
            cancelButton.heightAnchor.constraint(equalToConstant: 44),
            cancelButton.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
    }

    @objc private func close(_ sender: Any) {
        delegate?.addCredentialStatusViewControllerDidCancel(self)
    }
}
