import UIKit

final class ProviderLoadingViewController: UIViewController {
    weak var providerPickerCoordinator: ProviderPickerCoordinating?

    private let providerController: ProviderController

    private let activityIndicatorView = UIActivityIndicatorView(style: .medium)

    init(providerController: ProviderController) {
        self.providerController = providerController
        
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.background

        activityIndicatorView.startAnimating()
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicatorView)

        NotificationCenter.default.addObserver(self, selector: #selector(showLoadingIndicator), name: .providerControllerWillFetchProviders, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideLoadingIndicator), name: .providerControllerDidFetchProviders, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatedWithError(_:)), name: .providerControllerDidFailWithError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateProviders), name: .providerControllerDidUpdateProviders, object: nil)
    }

    @objc private func showLoadingIndicator() {
        DispatchQueue.main.async {
            activityIndicatorView.startAnimating()
        }
    }

    @objc private func hideLoadingIndicator() {
        DispatchQueue.main.async {
            activityIndicatorView.stopAnimating()
        }
    }

    @objc private func updateProviders() {
        DispatchQueue.main.async {
            providerPickerCoordinator.
        }
    }
}

