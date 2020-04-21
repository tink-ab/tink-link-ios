import UIKit
import TinkLink

protocol ProviderPickerCoordinating: AnyObject {
    func showFinancialInstitutionGroupNodes(for financialInstitutionGroupNodes: [ProviderTree.FinancialInstitutionGroupNode], title: String?)
    func showFinancialInstitution(for financialInstitutionNodes: [ProviderTree.FinancialInstitutionNode], name: String)
    func showAccessTypePicker(for accessTypeNodes: [ProviderTree.AccessTypeNode], name: String)
    func showCredentialsKindPicker(for credentialsKindNodes: [ProviderTree.CredentialsKindNode])
    func didSelectProvider(_ provider: Provider)
}

protocol ProviderPickerCoordinatorDelegate: AnyObject {
    func providerPickerCoordinatorShowLoading(_ coordinator: ProviderPickerCoordinator)
    func providerPickerCoordinatorHideLoading(_ coordinator: ProviderPickerCoordinator)
    func providerPickerCoordinatorUpdateProviders(_ coordinator: ProviderPickerCoordinator)
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

    func showFinancialInstitution(for financialInstitutionNodes: [ProviderTree.FinancialInstitutionNode], name: String) {
        let viewController = FinancialInstitutionPickerViewController(financialInstitutionNodes: financialInstitutionNodes)
        setupNavigationItem(for: viewController, title: name)
        viewController.providerPickerCoordinator = self
        parentViewController?.show(viewController, sender: nil)
    }

    func showAccessTypePicker(for accessTypeNodes: [ProviderTree.AccessTypeNode], name: String) {
        let viewController = AccessTypePickerViewController(accessTypeNodes: accessTypeNodes)
        let titleFormat = Strings.ProviderPicker.List.accessTypeTitle
        let formattedTitle = String(format: titleFormat, name)
        setupNavigationItem(for: viewController, title: formattedTitle)
        viewController.providerPickerCoordinator = self
        parentViewController?.show(viewController, sender: nil)
    }

    func showCredentialsKindPicker(for credentialsKindNodes: [ProviderTree.CredentialsKindNode]) {
        let viewController = CredentialsKindPickerViewController(credentialsKindNodes: credentialsKindNodes)
        let title = Strings.ProviderPicker.List.credentialTypeTitle
        setupNavigationItem(for: viewController, title: title)
        viewController.providerPickerCoordinator = self
        parentViewController?.show(viewController, sender: nil)
    }

    func didSelectProvider(_ provider: Provider) {
        completion?(.success(provider))
    }

    @objc private func showLoadingIndicator() {
        delegate?.providerPickerCoordinatorShowLoading(self)
    }

    @objc private func hideLoadingIndicator() {
        delegate?.providerPickerCoordinatorHideLoading(self)
    }

    @objc private func updateProviders() {
        delegate?.providerPickerCoordinatorUpdateProviders(self)
        DispatchQueue.main.async {
            self.showFinancialInstitutionGroupNodes(for: self.providerController.financialInstitutionGroupNodes, title: Strings.ProviderPicker.List.financialInstitutionsTitle)
        }
    }

    @objc private func updatedWithError() {
        delegate?.providerPickerCoordinatorShowError(self, error: providerController.error)
    }
}

