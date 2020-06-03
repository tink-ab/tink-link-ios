import UIKit

protocol LoadingViewControllerDelegate: AnyObject {
    func loadingViewControllerDidPressRetry(_ viewController: LoadingViewController)
}

final class LoadingViewController: UIViewController {
    
    weak var delegate: LoadingViewControllerDelegate?

    private let activityIndicatorView = ActivityIndicatorView()
    private let label = UILabel()
    private let errorView = ProviderLoadingErrorView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.background
        activityIndicatorView.tintColor = Color.accent

        activityIndicatorView.startAnimating()
        errorView.delegate = self
        errorView.isHidden = true

        errorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Font.headline
        label.numberOfLines = 0
        label.text = "TEST"
        label.textAlignment = .center
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(contentView)
        contentView.addSubview(label)
        contentView.addSubview(activityIndicatorView)

        view.addSubview(errorView)
        view.addSubview(activityIndicatorView)

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

    func update(_ text: String?) {
        DispatchQueue.main.async {
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
}

extension LoadingViewController: ProviderLoadingErrorViewDelegate {
    func reloadProviderList(providerLoadingErrorView: ProviderLoadingErrorView) {
        delegate?.loadingViewControllerDidPressRetry(self)
    }
}
