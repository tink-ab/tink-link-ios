@_exported import TinkCore
import Foundation

extension Tink {
    // MARK: - Handling Redirects

    /// For some providers the redirect needs to be a https link. Use the continue user activity method in your `UIApplicationDelegate` to let TinkLink send the information to Tink if needed.
    ///
    /// ```swift
    /// func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    ///     if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL {
    ///         return Tink.open(url)
    ///     } else {
    ///         return false
    ///     }
    /// }
    /// ```
    @available(iOS 9.0, *)
    @available(*, deprecated, message: "Use Tink.open(_:completion:) instead.")
    public func open(_ url: URL, completion: ((Result<Void, Error>) -> Void)? = nil) -> Bool {
        Tink.open(url, completion: completion)
    }

    /// Handles redirects from a third party authentication flow.
    ///
    /// Some providers will require additional information from the authentication to be sent back to Tink after the user authenticates within the third party app for the credential to be added successfully. This information will be included as part of the redirect URI when redirecting back to your app.
    ///
    /// If you use a return URL with a custom URL scheme, implement the open method in your `UIApplicationDelegate` to let Tink Link handle the information and send it back to Tink if needed.
    ///
    /// ```swift
    /// func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    ///     return Tink.open(url)
    /// }
    /// ```
    ///
    /// For some providers the redirect needs to be a `https` link. To handle those redirects your app needs to support universal links.
    ///
    /// If you use a universal link as the return URL, implement the continue user activity method in your `UIApplicationDelegate` instead.
    ///
    /// ```swift
    /// func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    ///     if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL {
    ///         return Tink.open(url)
    ///     } else {
    ///         return false
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - url: The URL to handle.
    ///   - completion: The block to execute when the information from the URL has been sent to Tink successfully or if it failed.
    /// - Returns: A Boolean indicating whether the URL was handled by Tink Link.
    @available(iOS 9.0, *)
    public static func open(_ url: URL, completion: ((Result<Void, Error>) -> Void)? = nil) -> Bool {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else { return false }

        let configurations = CredentialsContext.registeredConfigurations.filter({ url.absoluteString.starts(with: $0.redirectURI.absoluteString) })

        if configurations.isEmpty { return false }

        var parameters = Dictionary(grouping: urlComponents.queryItems ?? [], by: { $0.name })
            .compactMapValues { $0.first?.value }

        parameters.merge(urlComponents.fragmentParameters, uniquingKeysWith: { current, _ in current })
        guard let state = parameters.removeValue(forKey: "state") else { return false }

        let configurationsByClientID = Dictionary(grouping: configurations, by: \.clientID).compactMapValues(\.first)

        for configuration in configurationsByClientID.values {
            let tink = Tink(configuration: configuration)
            _ = tink.services.credentialsService.thirdPartyCallback(state: state, parameters: parameters) { result in
                completion?(result)
            }
        }

        return true
    }
}
