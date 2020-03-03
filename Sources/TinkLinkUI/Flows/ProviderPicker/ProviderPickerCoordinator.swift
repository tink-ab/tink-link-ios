import UIKit
import TinkLink

protocol ProviderPickerCoordinating: AnyObject {
    func showFinancialInstitutionGroupNodes(for financialInstitutionGroupNodes: [ProviderTree.FinancialInstitutionGroupNode], title: String?)
    func showFinancialInstitution(for financialInstitutionNodes: [ProviderTree.FinancialInstitutionNode], title: String?)
    func showAccessTypePicker(for accessTypeNodes: [ProviderTree.AccessTypeNode], title: String?)
    func showCredentialKindPicker(for credentialKindNodes: [ProviderTree.CredentialKindNode], title: String?)
    func didSelectProvider(_ provider: Provider)
}

protocol ProviderPickerCoordinatorDelegate: AnyObject {
    func providerPickerCoordinatorShowLoading(_ coordinator: ProviderPickerCoordinator)
    func providerPickerCoordinatorHideLoading(_ coordinator: ProviderPickerCoordinator)
    func providerPickerCoordinatorShowError(_ coordinator: ProviderPickerCoordinator, error: Error?)
}

class ProviderPickerCoordinator: ProviderPickerCoordinating {

    weak var delegate: ProviderPickerCoordinatorDelegate?

    private let providerController: ProviderController
    private weak var parentViewController: UIViewController?
    private var completion: ((Result<Provider, Error>) -> Void)?

    init(parentViewController: UIViewController, providerController: ProviderController) {
        self.providerController = providerController
        self.parentViewController = parentViewController
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func start(completion: @escaping ((Result<Provider, Error>) -> Void)) {
//        let providerLoadingViewController = ProviderLoadingViewController(providerController: providerController)
//        providerLoadingViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(Self.cancel))
//        providerLoadingViewController.providerPickerCoordinator = self
//        
//        parentViewController?.show(providerLoadingViewController, sender: self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showLoadingIndicator), name: .providerControllerWillFetchProviders, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideLoadingIndicator), name: .providerControllerDidFetchProviders, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatedWithError), name: .providerControllerDidFailWithError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateProviders), name: .providerControllerDidUpdateProviders, object: nil)
        
        self.completion = completion
    }

    private func setupNavigationItem(for viewController: UIViewController, title: String?) {
        viewController.title = title
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
    }

    @objc func cancel() {
        self.completion?(.failure(CocoaError(.userCancelled)))
    }

    func showFinancialInstitutionGroupNodes(for financialInstitutionGroupNodes: [ProviderTree.FinancialInstitutionGroupNode], title: String?) {
        let providerListViewController = ProviderListViewController(financialInstitutionGroupNodes: financialInstitutionGroupNodes)
        providerListViewController.navigationItem.hidesBackButton = true
        setupNavigationItem(for: providerListViewController, title: title)
        providerListViewController.providerPickerCoordinator = self

        UIView.performWithoutAnimation {
            self.parentViewController?.show(providerListViewController, sender: self)
        }
    }

    func showFinancialInstitution(for financialInstitutionNodes: [ProviderTree.FinancialInstitutionNode], title: String?) {
        let viewController = FinancialInstitutionPickerViewController(financialInstitutionNodes: financialInstitutionNodes)
        setupNavigationItem(for: viewController, title: title)
        viewController.providerPickerCoordinator = self
        parentViewController?.show(viewController, sender: nil)
    }

    func showAccessTypePicker(for accessTypeNodes: [ProviderTree.AccessTypeNode], title: String?) {
        let viewController = AccessTypePickerViewController(accessTypeNodes: accessTypeNodes)
        setupNavigationItem(for: viewController, title: title)
        viewController.providerPickerCoordinator = self
        parentViewController?.show(viewController, sender: nil)
    }

    func showCredentialKindPicker(for credentialKindNodes: [ProviderTree.CredentialKindNode], title: String?) {
        let viewController = CredentialKindPickerViewController(credentialKindNodes: credentialKindNodes)
        setupNavigationItem(for: viewController, title: title)
        viewController.providerPickerCoordinator = self
        parentViewController?.show(viewController, sender: nil)
    }

    func didSelectProvider(_ provider: Provider) {
        completion?(.success(provider))
    }

    @objc private func showLoadingIndicator() {
        delegate?.providerPickerCoordinatorShowLoading(self)
//        DispatchQueue.main.async {
//            self.activityIndicatorView.startAnimating()
//            self.errorView.isHidden = true
//        }
    }

    @objc private func hideLoadingIndicator() {
        delegate?.providerPickerCoordinatorHideLoading(self)
//        DispatchQueue.main.async {
//            self.activityIndicatorView.stopAnimating()
//        }
    }

    @objc private func updateProviders() {
        DispatchQueue.main.async {
            self.showFinancialInstitutionGroupNodes(for: self.providerController.financialInstitutionGroupNodes, title: "Choose Bank")
        }
    }

    @objc private func updatedWithError() {
        delegate?.providerPickerCoordinatorShowError(self, error: providerController.error)
//        DispatchQueue.main.async {
//            self.hideLoadingIndicator()
//            self.errorView.isHidden = false
//            self.errorView.configure(with: self.providerController.error)
//        }
    }
}

