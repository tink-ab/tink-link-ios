import UIKit
import TinkLink

final class AddCredentialFlow {

    weak var parentViewController: UIViewController?

    private let credentialController: CredentialController

    private var task: AddCredentialTask?
    private var statusViewController: AddCredentialStatusViewController?
    private var qrImageViewController: QRImageViewController?
    private var statusPresentationManager = AddCredentialStatusPresentationManager()

    init(credentialController: CredentialController, parentViewController: UIViewController) {
        self.parentViewController = parentViewController
        self.credentialController = credentialController
    }

    deinit {
        task?.cancel()
    }

    func addCredential(provider: Provider, form: Form, allowAnotherDevice: Bool, onCompletion: @escaping ((Result<Void, Error>) -> Void)) {

        task = credentialController.addCredential(
            provider,
            form: form,
            progressHandler: { [weak self] status in
                DispatchQueue.main.async {
                    self?.handleAddCredentialStatus(status, shouldAuthenticateInAnotherDevice: allowAnotherDevice)
                }
            },
            completion: { [weak self] result in
                DispatchQueue.main.async {
                    self?.handleAddCredentialCompletion(result, onCompletion: onCompletion)
                }
            }
        )
        self.showUpdating(status: "Authorizing...")
    }
    private func handleAddCredentialStatus(_ status: AddCredentialTask.Status, shouldAuthenticateInAnotherDevice: Bool = false) {
        switch status {
        case .authenticating, .created:
            break
        case .awaitingSupplementalInformation(let supplementInformationTask):
            showSupplementalInformation(for: supplementInformationTask)
        case .awaitingThirdPartyAppAuthentication(let thirdPartyAppAuthenticationTask):
            if shouldAuthenticateInAnotherDevice {
                thirdPartyAppAuthenticationTask.qr { [weak self] qrImage in
                    DispatchQueue.main.async {
                        self?.showQRCodeView(qrImage: qrImage)
                    }
                }
            } else {
                 thirdPartyAppAuthenticationTask.openThirdPartyApp()
            }
        case .updating(let status):
            showUpdating(status: status)
        }
    }

    private func handleAddCredentialCompletion(_ result: Result<Credential, Error>, onCompletion: @escaping ((Result<Void, Error>) -> Void)) {
        do {
            _ = try result.get()
            hideUpdatingView(animated: true) {
                onCompletion(.success(()))
            }
        } catch {
            self.hideUpdatingView(animated: true) {
                onCompletion(.failure(error))
            }
        }
        task = nil
    }
}

extension AddCredentialFlow {
    private func showSupplementalInformation(for supplementInformationTask: SupplementInformationTask) {
        hideUpdatingView(animated: true) {
            let supplementalInformationViewController = SupplementalInformationViewController(supplementInformationTask: supplementInformationTask)
            supplementalInformationViewController.delegate = self
            let navigationController = TinkNavigationController(rootViewController: supplementalInformationViewController)
            self.parentViewController?.show(navigationController, sender: nil)
        }
    }

    private func showUpdating(status: String) {
        hideQRCodeView {
            if self.statusViewController == nil {
                let statusViewController = AddCredentialStatusViewController()
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
        hideQRCodeView(animated: animated)
        guard statusViewController != nil else {
            completion?()
            return
        }
        parentViewController?.dismiss(animated: animated, completion: completion)
        statusViewController = nil
    }

    private func showQRCodeView(qrImage: UIImage) {
        hideUpdatingView {
            let qrImageViewController = QRImageViewController(qrImage: qrImage)
            self.qrImageViewController = qrImageViewController
            self.parentViewController?.present(qrImageViewController, animated: true)
        }
    }

    private func hideQRCodeView(animated: Bool = false, completion: (() -> Void)? = nil) {
        guard qrImageViewController != nil else {
            completion?()
            return
        }
        parentViewController?.dismiss(animated: animated, completion: completion)
        qrImageViewController = nil
    }
}

// MARK: - SupplementalInformationViewControllerDelegate

extension AddCredentialFlow: SupplementalInformationViewControllerDelegate {
    func supplementalInformationViewControllerDidCancel(_ viewController: SupplementalInformationViewController) {
        parentViewController?.dismiss(animated: true)
    }

    func supplementalInformationViewController(_ viewController: SupplementalInformationViewController, didSupplementInformationForCredential credential: Credential) {
        parentViewController?.dismiss(animated: true) {
            self.showUpdating(status: "Sending...")
        }
    }
}
