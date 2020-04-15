import UIKit
import TinkLink

final class AddCredentialsSession {

    weak var parentViewController: UIViewController?

    private let providerController: ProviderController
    private let credentialsController: CredentialsController
    private let authorizationController: AuthorizationController
    private let scopes: [Scope]

    private var task: AddCredentialsTask?
    private var supplementInfoTask: SupplementInformationTask?

    private var statusViewController: AddCredentialsStatusViewController?
    private weak var qrImageViewController: QRImageViewController?
    private var statusPresentationManager = AddCredentialStatusPresentationManager()

    private var authorizationCode: AuthorizationCode?
    private var didCallAuthorize = false
    private var authorizationGroup = DispatchGroup()

    private var timer: Timer?

    init(providerController: ProviderController, credentialsController: CredentialsController, authorizationController: AuthorizationController, scopes: [Scope], parentViewController: UIViewController) {
        self.parentViewController = parentViewController
        self.providerController = providerController
        self.credentialsController = credentialsController
        self.scopes = scopes
        self.authorizationController = authorizationController
    }

    deinit {
        task?.cancel()
        timer?.invalidate()
    }

    private func countUpdatingProcessTime() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 45.0, repeats: false) { [weak self] timer in
            self?.showUpdating(status: "Process is taking longer than expected")
        }
    }

    func addCredential(provider: Provider, form: Form, onCompletion: @escaping ((Result<AuthorizationCode, Error>) -> Void)) {

        task = credentialsController.addCredentials(
            provider,
            form: form,
            progressHandler: { [weak self] status in
                DispatchQueue.main.async {
                    self?.handleAddCredentialStatus(status) {
                        [weak self] error in
                        DispatchQueue.main.async {
                            self?.hideUpdatingView(animated: true) {
                                onCompletion(.failure(error))
                            }
                            self?.task?.cancel()
                            self?.task = nil
                        }
                    }
                }
            },
            completion: { [weak self] result in
                DispatchQueue.main.async {
                    self?.handleAddCredentialsCompletion(result, onCompletion: onCompletion)
                }
            }
        )
        self.showUpdating(status: NSLocalizedString("AddCredentials.Status.Authorizing", tableName: "TinkLinkUI", bundle: .tinkLinkUI, value: "Authorizing…", comment: "Text shown when adding credentials and waiting for authorization."))
    }

    private func handleAddCredentialStatus(_ status: AddCredentialsTask.Status, onError: @escaping (Error) -> Void) {
        switch status {
        case .created, .authenticating:
            break
        case .awaitingSupplementalInformation(let supplementInformationTask):
            showSupplementalInformation(for: supplementInformationTask)
        case .awaitingThirdPartyAppAuthentication(let thirdPartyAppAuthenticationTask):
            handleThirdPartyAppAuthentication(task: thirdPartyAppAuthenticationTask)
        case .updating:
            let status: String
            if let providerID = task?.credentials?.providerID, let bankName = providerController.provider(providerID: providerID)?.displayName {
                let statusFormatText = NSLocalizedString("AddCredentials.Status.Updating", tableName: "TinkLinkUI", bundle: .tinkLinkUI, value: "Connecting to %@, please wait…", comment: "Text shown when updating credentials.")
                status = String(format: statusFormatText, bankName)
            } else {
                status = NSLocalizedString("AddCredentials.Status.Updating.Fallback", tableName: "TinkLinkUI", bundle: .tinkLinkUI, value: "Connection, please wait…", comment: "Fallback text shown when fail to get bank name while updating credentials.")
            }
            showUpdating(status: status)
            countUpdatingProcessTime()
            authorizeIfNeeded(onError: onError)
        }
    }

    private func handleThirdPartyAppAuthentication(task: ThirdPartyAppAuthenticationTask) {
        task.handle { [weak self] result in
            switch result {
            case .qrImage(let image):
                DispatchQueue.main.async {
                    self?.showQRCodeView(qrImage: image)
                }
            case .awaitAuthenticationOnAnotherDevice:
                DispatchQueue.main.async {
                    self?.showUpdating(status: NSLocalizedString("AddCredentials.Status.WaitingForAuthenticationOnAnotherDevice", tableName: "TinkLinkUI", bundle: .tinkLinkUI, value: "Waiting for authentication on another device", comment: "Text shown when adding credentials and waiting for authenticvation on another device."))
                }
            }
        }
    }

    private func handleAddCredentialsCompletion(_ result: Result<Credentials, Error>, onCompletion: @escaping ((Result<AuthorizationCode, Error>) -> Void)) {
        timer?.invalidate()
        authorizeIfNeeded(onError: { [weak self] error in
            DispatchQueue.main.async {
                self?.hideUpdatingView(animated: true) {
                    onCompletion(.failure(error))
                }
            }
        })
        do {
            _ = try result.get()
            authorizationGroup.notify(queue: .main) { [weak self] in
                if let authorizationCode = self?.authorizationCode {
                    self?.hideUpdatingView(animated: true) {
                        onCompletion(.success(authorizationCode))
                    }
                }
            }
        } catch {
            hideUpdatingView(animated: true) {
                onCompletion(.failure(error))
            }
        }
        task = nil
    }

    private func authorizeIfNeeded(onError: @escaping (Error) -> Void) {
        if didCallAuthorize { return }

        didCallAuthorize = true
        authorizationGroup.enter()
        authorizationController.authorize(scopes: scopes) { [weak self] result in
            do {
                let authorizationCode = try result.get()
                self?.authorizationCode = authorizationCode
            } catch {
                onError(AddCredentialsTask.Error.temporaryFailure("A temporary error has occurred"))
            }
            self?.authorizationGroup.leave()
        }
    }
}

extension AddCredentialsSession {
    private func showSupplementalInformation(for supplementInformationTask: SupplementInformationTask) {
        self.supplementInfoTask = supplementInformationTask
        hideUpdatingView(animated: true) {
            let supplementalInformationViewController = SupplementalInformationViewController(supplementInformationTask: supplementInformationTask)
            supplementalInformationViewController.delegate = self
            let navigationController = TinkNavigationController(rootViewController: supplementalInformationViewController)
            self.parentViewController?.show(navigationController, sender: nil)
        }
    }

    private func showUpdating(status: String) {
        hideQRCodeViewIfNeeded {
            if let statusViewController = self.statusViewController {
                if statusViewController.presentingViewController == nil {
                    self.parentViewController?.present(statusViewController, animated: true)
                }
            } else {
                let statusViewController = AddCredentialsStatusViewController()
                statusViewController.delegate = self
                statusViewController.modalTransitionStyle = .crossDissolve
                statusViewController.modalPresentationStyle = .custom
                statusViewController.transitioningDelegate = self.statusPresentationManager
                self.parentViewController?.present(statusViewController, animated: true)
                self.statusViewController = statusViewController
            }
            self.statusViewController?.status = status
        }
    }

    private func hideUpdatingView(animated: Bool = false, completion: (() -> Void)? = nil) {
        hideQRCodeViewIfNeeded(animated: animated)
        guard statusViewController != nil, statusViewController?.presentingViewController != nil else {
            completion?()
            return
        }
        parentViewController?.dismiss(animated: animated, completion: completion)
    }

    private func showQRCodeView(qrImage: UIImage) {
        hideUpdatingView {
            let qrImageViewController = QRImageViewController(qrImage: qrImage)
            self.qrImageViewController = qrImageViewController
            qrImageViewController.delegate = self
            self.parentViewController?.present(TinkNavigationController(rootViewController: qrImageViewController), animated: true)
        }
    }

    private func hideQRCodeViewIfNeeded(animated: Bool = false, completion: (() -> Void)? = nil) {
        guard qrImageViewController != nil else {
            completion?()
            return
        }
        parentViewController?.dismiss(animated: animated, completion: completion)
    }
}

// MARK: - AddCredentialsStatusViewControllerDelegate

extension AddCredentialsSession: AddCredentialsStatusViewControllerDelegate {
    func addCredentialsStatusViewControllerDidCancel(_ viewController: AddCredentialsStatusViewController) {
        task?.cancel()
        timer?.invalidate()
        hideUpdatingView(animated: true) 
    }
}

// MARK: - SupplementalInformationViewControllerDelegate

extension AddCredentialsSession: SupplementalInformationViewControllerDelegate {
    func supplementalInformationViewControllerDidCancel(_ viewController: SupplementalInformationViewController) {
        parentViewController?.dismiss(animated: true) {
            self.supplementInfoTask?.cancel()
            self.showUpdating(status: NSLocalizedString("AddCredentials.Status.Canceling", tableName: "TinkLinkUI", bundle: .tinkLinkUI, value: "Canceling…", comment: "Text shown when canceling supplementing information."))
        }
    }

    func supplementalInformationViewController(_ viewController: SupplementalInformationViewController, didPressSubmitWithForm form: Form) {
        parentViewController?.dismiss(animated: true) {
            self.supplementInfoTask?.submit(form)
            self.showUpdating(status: NSLocalizedString("AddCredentials.Status.Sending", tableName: "TinkLinkUI", bundle: .tinkLinkUI, value: "Sending…", comment: "Text shown when submitting supplemental information."))
        }
    }
}

extension AddCredentialsSession: QRImageViewControllerDelegate {
    func qrImageViewControllerDidCancel(_ viewController: QRImageViewController) {
        parentViewController?.dismiss(animated: true) {
            self.task?.cancel()
        }
    }
}
