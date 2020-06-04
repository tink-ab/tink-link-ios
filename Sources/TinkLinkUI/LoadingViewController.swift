import UIKit

protocol LoadingViewControllerDelegate: AnyObject {
    func loadingViewControllerDidPressRetry(_ viewController: LoadingViewController)
}

final class LoadingViewController: UIViewController {
    
    weak var delegate: LoadingViewControllerDelegate?

    var onCancel: (() -> Void)?

    private let activityIndicatorView = ActivityIndicatorView()
    private let label = UILabel()
    private let cancelButton = UIButton(type: .system)
    private let errorView = ProviderLoadingErrorView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.background
        activityIndicatorView.tintColor = Color.accent

        activityIndicatorView.startAnimating()
        errorView.delegate = self
        errorView.isHidden = true

        cancelButton.setTitleColor(Color.accent, for: .normal)
        cancelButton.titleLabel?.font = Font.headline
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        cancelButton.setTitle("Cancel", for: .normal)

        label.font = Font.headline
        label.numberOfLines = 0
        label.textAlignment = .center

        label.translatesAutoresizingMaskIntoConstraints = false
        errorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(contentView)
        contentView.addSubview(label)
        contentView.addSubview(activityIndicatorView)

        view.addSubview(cancelButton)
        view.addSubview(activityIndicatorView)
        view.addSubview(errorView)

        NSLayoutConstraint.activate([
            activityIndicatorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            activityIndicatorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicatorView.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -24),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            contentView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            contentView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32),
            contentView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),

            cancelButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.topAnchor.constraint(equalTo: view.topAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func showLoadingIndicator() {
        DispatchQueue.main.async {
            self.activityIndicatorView.startAnimating()
            self.errorView.isHidden = true
        }
    }

    func hideLoadingIndicator() {
        DispatchQueue.main.async {
            self.activityIndicatorView.stopAnimating()
        }
    }

    func update(_ text: String?, onCancel: (() -> Void)?) {
        DispatchQueue.main.async {
            if let onCancel = onCancel {
                self.onCancel = onCancel
                self.cancelButton.isHidden = false
            } else {
                self.cancelButton.isHidden = true
            }

            self.label.text = text
        }
    }

    func setError(_ error: Error?) {
        DispatchQueue.main.async {
            self.hideLoadingIndicator()
            self.errorView.isHidden = false
            self.errorView.configure(with: error)
        }
    }

    @objc private func cancel() {
        onCancel?()
    }
}

extension LoadingViewController: ProviderLoadingErrorViewDelegate {
    func reloadProviderList(providerLoadingErrorView: ProviderLoadingErrorView) {
        delegate?.loadingViewControllerDidPressRetry(self)
    }
}
