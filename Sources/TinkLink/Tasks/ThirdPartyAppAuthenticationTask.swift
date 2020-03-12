import Foundation
#if os(iOS)
    import UIKit
#endif

/// A task that handles opening third party apps.
///
/// This task is provided when an `AddCredentialsTask`'s status changes to `awaitingThirdPartyAppAuthentication`.
///
/// When a credentials' status is `awaitingThirdPartyAppAuthentication` the user needs to authenticate in a third party app to finish adding the credentials.
///
/// When you receive a `awaitingThirdPartyAppAuthentication` status you should try to open the url provided in the  `ThirdPartyAppAuthentication` object. Check if the system can open the url or ask the user to download the app like this:
///
/// ```swift
/// if let deepLinkURL = thirdPartyAppAuthentication.deepLinkURL, UIApplication.shared.canOpenURL(deepLinkURL) {
///     UIApplication.shared.open(deepLinkURL)
/// } else {
///     <#Ask user to download app#>
/// }
/// ```
///
/// Here's how you can ask the user to download the third party app via an alert:
///
/// ```swift
/// let alertController = UIAlertController(title: thirdPartyAppAuthentication.downloadTitle, message: thirdPartyAppAuthentication.downloadMessage, preferredStyle: .alert)
///
/// if let appStoreURL = thirdPartyAppAuthentication.appStoreURL, UIApplication.shared.canOpenURL(appStoreURL) {
///     let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
///     let downloadAction = UIAlertAction(title: "Download", style: .default, handler: { _ in
///         UIApplication.shared.open(appStoreURL)
///     })
///     alertController.addAction(cancelAction)
///     alertController.addAction(downloadAction)
/// } else {
///     let okAction = UIAlertAction(title: "OK", style: .default)
///     alertController.addAction(okAction)
/// }
///
/// present(alertController, animated: true)
/// ```
///
/// After the redirect to the third party app, some providers requires additional information to be sent to Tink after the user authenticates with the third party app for the credential to be added successfully. This information is passed to your app via the redirect URI. Use the open method in your `UIApplicationDelegate` to let TinkLink send the information to Tink if needed.
/// ```swift
/// func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
///     return TinkLink.shared.open(url)
/// }
/// ```
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

        public var errorDescription: String? {
            switch self {
            case .deeplinkURLNotFound:
                return nil
            case .downloadRequired(let title, _, _):
                return title
            }
        }

        public var failureReason: String? {
            switch self {
            case .deeplinkURLNotFound:
                return nil
            case .downloadRequired(_, let message, _):
                return message
            }
        }

        public var appStoreURL: URL? {
            switch self {
            case .deeplinkURLNotFound:
                return nil
            case .downloadRequired(_, _, let url):
                return url
            }
        }
    }

    /// Information about how to open or download the third party application app.
    public private(set) var thirdPartyAppAuthentication: Credentials.ThirdPartyAppAuthentication

    private let completionHandler: (Result<Void, Swift.Error>) -> Void

    init(thirdPartyAppAuthentication: Credentials.ThirdPartyAppAuthentication, completionHandler: @escaping (Result<Void, Swift.Error>) -> Void) {
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

    // MARK: - Controlling the Task

    /// Tells the task to stop waiting for third party app authentication.
    ///
    /// Call this method if you have a UI that lets the user choose to open the third party app and the user cancels.
    public func cancel() {
        completionHandler(.failure(CocoaError(.userCancelled)))
    }
}
