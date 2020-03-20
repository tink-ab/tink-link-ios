import UIKit

final class LoadingViewController: UIViewController {
    weak var providerPickerCoordinator: ProviderPickerCoordinating?

    private let providerController: ProviderController

    private let activityIndicatorView = ActivityIndicatorView()
    private let errorView = ProviderLoadingErrorView()

    init(providerController: ProviderController) {
        self.providerController = providerController
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.background
        activityIndicatorView.tintColor = Color.accent

        activityIndicatorView.startAnimating()
        errorView.delegate = self
        errorView.isHidden = true

        if !providerController.isFetching, let error = providerController.error {
            update(error)
        } else {
            showLoadingIndicator()
        }

        errorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(errorView)
        view.addSubview(activityIndicatorView)

        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

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

    func update(_ error: Error?) {
        DispatchQueue.main.async {
            self.hideLoadingIndicator()
            self.errorView.isHidden = false
            self.errorView.configure(with: error)
        }
    }
}

extension LoadingViewController: ProviderLoadingErrorViewDelegate {
    func reloadProviderList(providerLoadingErrorView: ProviderLoadingErrorView) {
        providerController.performFetch()
    }
}
