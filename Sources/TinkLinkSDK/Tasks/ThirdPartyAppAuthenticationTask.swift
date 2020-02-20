import Foundation
#if os(iOS)
    import UIKit
#endif

/// A task that handles opening third party apps.
///
/// This task is provided when an `AddCredentialTask`'s status changes to `awaitingThirdPartyAppAuthentication`.
///
/// When a credential's status is `awaitingThirdPartyAppAuthentication` the user needs to authenticate in a third party app to finish adding the credential.
///
/// - Note: If the app couldn't be opened you need to handle the `AddCredentialTask` completion result and check for a `ThirdPartyAppAuthenticationTask.Error`.
/// This error can tell you if the user needs to download the app.
public class ThirdPartyAppAuthenticationTask: Identifiable {
    /// Error associated with the `ThirdPartyAppAuthenticationTask`.
    public enum Error: Swift.Error, LocalizedError {
        /// The `ThirdPartyAppAuthenticationTask` have no deep link URL.
        case deeplinkURLNotFound
        /// The `UIApplication` could not open the application. It is most likely missing and needs to be downloaded.
        case downloadRequired(title: String, message: String, appStoreURL: URL?)

        case doesNotSupportAuthenticatingOnAnotherDevice

        case decodingQRCodeImageFailed

        public var errorDescription: String? {
            switch self {
            case .deeplinkURLNotFound:
                return nil
            case .downloadRequired(let title, _, _):
                return title
            case .doesNotSupportAuthenticatingOnAnotherDevice:
                // TODO: Copy
                return "This bank does not support authenticating on another device"
            case .decodingQRCodeImageFailed:
                // TODO: Copy
                return "Failed to decode the QR code image"
            }
        }

        public var failureReason: String? {
            switch self {
            case .deeplinkURLNotFound:
                return nil
            case .downloadRequired(_, let message, _):
                return message
            case .doesNotSupportAuthenticatingOnAnotherDevice:
                // TODO: Copy
                return nil
            case .decodingQRCodeImageFailed:
                // TODO: Copy
                return nil
            }
        }

        public var appStoreURL: URL? {
            switch self {
            case .deeplinkURLNotFound:
                return nil
            case .downloadRequired(_, _, let url):
                return url
            case .doesNotSupportAuthenticatingOnAnotherDevice:
                return nil
            case .decodingQRCodeImageFailed:
                return nil
            }
        }
    }

    /// Information about how to open or download the third party application app.
    public private(set) var thirdPartyAppAuthentication: Credential.ThirdPartyAppAuthentication
    private let completionHandler: (Result<Void, Swift.Error>) -> Void
    private var canAuthenticateOnAnotherDevice: Bool {
        // TODO: Double check the logic.
        // Not sure about this part, but maybe because of grpc, the supplemental info is always empty for bankid credential kind, so has to check the deeplink URL instead.
        // Also maybe this is not even the case, for the bank that does not have autostart token, seems it will just trigger the bankID on another device with personal number
        thirdPartyAppAuthentication.deepLinkURL?.query?.contains("autostartToken") ?? false
    }

    private let credentialID: Credential.ID
    private let credentialService: CredentialService
    private var callRetryCancellable: RetryCancellable?

    init(credentialID: Credential.ID, thirdPartyAppAuthentication: Credential.ThirdPartyAppAuthentication, credentialService: CredentialService, completionHandler: @escaping (Result<Void, Swift.Error>) -> Void) {
        self.credentialID = credentialID
        self.credentialService = credentialService
        self.thirdPartyAppAuthentication = thirdPartyAppAuthentication
        self.completionHandler = completionHandler
    }

    // MARK: - Opening an App

    #if os(iOS)
        /// Tries to open the third party app.
        ///
        /// - Parameter application: The object that controls and coordinates your app. Defaults to the shared instance.
        public func openThirdPartyApp(with application: UIApplication = .shared) {
            guard let url = thirdPartyAppAuthentication.deepLinkURL else {
                completionHandler(.failure(Error.deeplinkURLNotFound))
                return
            }

            let downloadRequiredError = Error.downloadRequired(
                title: thirdPartyAppAuthentication.downloadTitle,
                message: thirdPartyAppAuthentication.downloadMessage,
                appStoreURL: thirdPartyAppAuthentication.appStoreURL
            )

            DispatchQueue.main.async {
                application.open(url, options: [.universalLinksOnly: NSNumber(value: true)]) { didOpenUniversalLink in
                    if didOpenUniversalLink {
                        self.completionHandler(.success(()))
                    } else {
                        application.open(url, options: [:], completionHandler: { didOpen in
                            if didOpen {
                                self.completionHandler(.success(()))
                            } else {
                                self.completionHandler(.failure(downloadRequiredError))
                            }
                        })
                    }
                }
            }
        }
    #endif

    public func qr(completion: @escaping (UIImage) -> Void) {
        if canAuthenticateOnAnotherDevice {
            callRetryCancellable = credentialService.qr(credentialID: credentialID) { [weak self] result in
                do {
                    let qrData = try result.get()
                    guard let qrImage = UIImage(data: qrData) else {
                        throw Error.decodingQRCodeImageFailed
                    }
                    self?.completionHandler(.success(()))
                    completion(qrImage)
                } catch {
                    self?.completionHandler(.failure(error))
                }
                self?.callRetryCancellable = nil
            }
        } else {
            completionHandler(.failure(Error.doesNotSupportAuthenticatingOnAnotherDevice))
        }
    }

    // MARK: - Controlling the Task

    /// Tells the task to stop waiting for third party app authentication.
    ///
    /// Call this method if you have a UI that lets the user choose to open the third party app and the user cancels.
    public func cancel() {
        callRetryCancellable?.cancel()
        callRetryCancellable = nil
        completionHandler(.failure(CocoaError(.userCancelled)))
    }
}
