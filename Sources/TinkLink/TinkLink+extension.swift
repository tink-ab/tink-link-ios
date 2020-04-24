@_exported import TinkCore
import Foundation

extension Tink {

    public enum UserError: Swift.Error {
        /// The market and/or locale was invalid. The payload from the backend can be found in the associated value.
        case invalidMarketOrLocale(String)

        init?(createTemporaryUserError error: Swift.Error) {
            switch error {
            case ServiceError.invalidArgument(let message):
                self = .invalidMarketOrLocale(message)
            default:
                return nil
            }
        }
    }

    // MARK: - Handling Redirects

    ///
    /// For some providers the redirect needs to be a https link. Use the continue user activity method in your `UIApplicationDelegate` to let TinkLink send the information to Tink if needed.
    ///
    /// ```swift
    /// func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    ///     if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL {
    ///         return TinkLink.shared.open(url)
    ///     } else {
    ///         return false
    ///     }
    /// }
    /// ```
    @available(iOS 9.0, *)
    public func open(_ url: URL, completion: ((Result<Void, Error>) -> Void)? = nil) -> Bool {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            urlComponents.string?.starts(with: configuration.redirectURI.absoluteString) ?? false
        else { return false }

        var parameters = Dictionary(grouping: urlComponents.queryItems ?? [], by: { $0.name })
            .compactMapValues { $0.first?.value }

        parameters.merge(urlComponents.fragmentParameters, uniquingKeysWith: { (current, _) in current })

        NotificationCenter.default.post(name: .credentialThirdPartyCallback, object: nil, userInfo: parameters)

        return true
    }

    // MARK: - Authenticating a User

    /// Authenticate a permanent user with authorization code.
    ///
    /// - Parameter authorizationCode: Authenticate with a `AuthorizationCode` that delegated from Tink to exchanged for a user object.
    /// - Parameter completion: A result representing either a success or an error.
    @discardableResult
    public func authenticateUser(authorizationCode: AuthorizationCode, completion: @escaping (Result<Void, Swift.Error>) -> Void) -> RetryCancellable? {
        return oAuthService.authenticate(code: authorizationCode, completion: { [weak self] result in
            do {
                let authenticateResponse = try result.get()
                let accessToken = authenticateResponse.accessToken
                self?.setCredential(.accessToken(accessToken.rawValue))
                completion(.success)
            } catch {
                completion(.failure(error))
            }
        })
    }

    /// Create a user for a specific market and locale.
    ///
    /// :nodoc:
    ///
    /// - Parameter market: Register a `Market` for creating the user, will use the default market if nothing is provided.
    /// - Parameter locale: Register a `Locale` for creating the user, will use the default locale in TinkLink if nothing is provided.
    /// - Parameter completion: A result representing either a success or an error.
    @discardableResult
    public func _createTemporaryUser(for market: Market, locale: Locale = Tink.defaultLocale, completion: @escaping (Result<Void, Swift.Error>) -> Void) -> RetryCancellable? {
        return oAuthService.createAnonymous(market: market, locale: locale, origin: nil) { [weak self] result in
            let mappedResult = result.mapError { UserError(createTemporaryUserError: $0) ?? $0 }
            do {
                let accessToken = try mappedResult.get()
                self?.setCredential(.accessToken(accessToken.rawValue))
                completion(.success)
            } catch {
                completion(.failure(error))
            }
        }
    }
}
