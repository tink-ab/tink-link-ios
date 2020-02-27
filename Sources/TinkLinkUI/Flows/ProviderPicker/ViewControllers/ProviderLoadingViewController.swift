import UIKit

final class ProviderLoadingViewController: UIViewController {
    weak var providerPickerCoordinator: ProviderPickerCoordinating?

    private let providerController: ProviderController

    private let activityIndicatorView = UIActivityIndicatorView(style: .gray)
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

        NotificationCenter.default.addObserver(self, selector: #selector(showLoadingIndicator), name: .providerControllerWillFetchProviders, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideLoadingIndicator), name: .providerControllerDidFetchProviders, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatedWithError), name: .providerControllerDidFailWithError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateProviders), name: .providerControllerDidUpdateProviders, object: nil)

        view.backgroundColor = Color.background

        activityIndicatorView.startAnimating()
        errorView.delegate = self
        errorView.isHidden = true

        if !providerController.isFetching {
            if providerController.error != nil {
                updatedWithError()
            } else {
                updateProviders()
            }
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

    @objc private func showLoadingIndicator() {
        DispatchQueue.main.async {
            self.activityIndicatorView.startAnimating()
            self.errorView.isHidden = true
        }
    }

    @objc private func hideLoadingIndicator() {
        DispatchQueue.main.async {
            self.activityIndicatorView.stopAnimating()
        }
    }

    @objc private func updateProviders() {
        DispatchQueue.main.async {
            self.providerPickerCoordinator?.showFinancialInstitutionGroupNodes(for: self.providerController.financialInstitutionGroupNodes, title: "Choose Bank")
        }
    }

    @objc private func updatedWithError() {
        DispatchQueue.main.async {
            self.hideLoadingIndicator()
            self.errorView.isHidden = false
            self.errorView.show(self.providerController.error)
        }
    }
}

extension ProviderLoadingViewController: ProviderLoadingErrorViewDelegate {
    func reloadProviderList(providerLoadingErrorView: ProviderLoadingErrorView) {
        showLoadingIndicator()
        providerController.performFetch()
    }
}
