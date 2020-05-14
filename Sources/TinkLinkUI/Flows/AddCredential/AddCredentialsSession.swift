import UIKit
import TinkLink

final class AddCredentialsSession {

    weak var parentViewController: UIViewController?

    private let providerController: ProviderController
    private let credentialsController: CredentialsController
    private let authorizationController: AuthorizationController
    private let scopes: [Scope]

    private var task: Cancellable?

    private var supplementInfoTask: SupplementInformationTask?

    private var statusViewController: AddCredentialsStatusViewController?
    private weak var qrImageViewController: QRImageViewController?
    private var statusPresentationManager = AddCredentialsStatusPresentationManager()

    private var authorizationCode: AuthorizationCode?
    private var didCallAuthorize = false
    private var authorizationGroup = DispatchGroup()

    private var timer: Timer?
    private var providerID: Provider.ID?

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
            scopes: scopes, 
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
        providerID = provider.id
        self.showUpdating(status: Strings.AddCredentials.Status.authorizing)
    }

    func updateCredentials(credentials: Credentials, form: Form, completion: @escaping (Result<Credentials, Error>) -> Void) {
        task = credentialsController.update(credentials, form: form, shouldFailOnThirdPartyAppAuthenticationDownloadRequired: false, progressHandler: { [weak self] status in
            DispatchQueue.main.async {
                self?.handleUpdateTaskStatus(status)
            }
            }, completion: completion)
        providerID = credentials.providerID
    }

    func refreshCredentials(credentials: Credentials, completion: @escaping (Result<Credentials, Error>) -> Void) {
        task = credentialsController.refresh(credentials, progressHandler: { [weak self] status in
            DispatchQueue.main.async {
                self?.handleUpdateTaskStatus(status)
            }
        }, completion: completion)
    }

    func authenticateCredentials(credentials: Credentials, completion: @escaping (Result<Credentials, Error>) -> Void) {
        task = credentialsController.authenticate(credentials, progressHandler: { [weak self] status in
            DispatchQueue.main.async {
                self?.handleUpdateTaskStatus(status)
            }
        }, completion: completion)
        providerID = credentials.providerID
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
            if let providerID = providerID, let bankName = providerController.provider(providerID: providerID)?.displayName {
                let statusFormatText = Strings.AddCredentials.Status.updating
                status = String(format: statusFormatText, bankName)
            } else {
                status = Strings.AddCredentials.Status.updatingFallback
            }
            showUpdating(status: status)
            countUpdatingProcessTime()
            authorizeIfNeeded(onError: onError)
        }
    }

    private func handleUpdateTaskStatus(_ status: UpdateCredentialsTask.Status) {
        switch status {
        case .authenticating:
            break
        case .awaitingSupplementalInformation(let supplementInformationTask):
            showSupplementalInformation(for: supplementInformationTask)
        case .awaitingThirdPartyAppAuthentication(let thirdPartyAppAuthenticationTask):
        handleThirdPartyAppAuthentication(task: thirdPartyAppAuthenticationTask)
        case .updating:
            let status: String
            if let providerID = providerID, let bankName = providerController.provider(providerID: providerID)?.displayName {
                let statusFormatText = Strings.AddCredentials.Status.updating
                status = String(format: statusFormatText, bankName)
            } else {
                status = Strings.AddCredentials.Status.updatingFallback
            }
            showUpdating(status: status)
            countUpdatingProcessTime()
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
                    self?.showUpdating(status: Strings.AddCredentials.Status.waitingForAuthenticationOnAnotherDevice)
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
            self.showUpdating(status: Strings.AddCredentials.Status.cancelling)
        }
    }

    func supplementalInformationViewController(_ viewController: SupplementalInformationViewController, didPressSubmitWithForm form: Form) {
        parentViewController?.dismiss(animated: true) {
            self.supplementInfoTask?.submit(form)
            self.showUpdating(status: Strings.AddCredentials.Status.sending)
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
