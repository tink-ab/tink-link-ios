import Foundation
#if os(iOS)
    import UIKit
#endif

/// The `Tink` class encapsulates a connection to the Tink API.
///
/// By default a shared `Tink` instance will be used, but you can also create your own
/// instance and use that instead. This allows you to use multiple `Tink` instances at the
/// same time.
public class Tink {
    static var _shared: Tink?

    // MARK: - Using the Shared Instance

    /// The shared `TinkLink` instance.
    ///
    /// Note: You need to configure the shared instance by calling `TinkLink.configure(with:)`
    /// before accessing the shared instance. Not doing so will cause a run-time error.
    public static var shared: Tink {
        guard let shared = _shared else {
            fatalError("Configure Tink Link by calling `TinkLink.configure(with:)` before accessing the shared instance")
        }
        return shared
    }

    private var authorizationBehavior = AuthorizationHeaderClientBehavior(sessionCredential: nil)
    private lazy var oAuthService = RESTOAuthService(client: client)
    private(set) var client: RESTClient

    // MARK: - Specifying the Credential

    /// Sets the credential to be used for this Tink Context.
    ///
    /// The credential is associated with a specific user which has been
    /// created and authenticated through the Tink API.
    ///
    /// - Parameter credential: The credential to use.
    public func setCredential(_ credential: SessionCredential?) {
        authorizationBehavior.sessionCredential = credential
    }

    // MARK: - Creating a Tink Link Object

    private convenience init() {
        do {
            let configuration = try Configuration(processInfo: .processInfo)
            self.init(configuration: configuration)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    /// Create a Tink instance with a custom configuration.
    /// - Parameters:
    ///   - configuration: The configuration to be used.
    public init(configuration: Configuration) {
        self.configuration = configuration
        let certificateURL = configuration.restCertificateURL
        let certificate = certificateURL.flatMap { try? String(contentsOf: $0, encoding: .utf8) }
        self.client = RESTClient(restURL: self.configuration.environment.restURL, certificates: certificate, behavior: ComposableClientBehavior(
            behaviors: [
                SDKHeaderClientBehavior(sdkName: "Tink Link iOS", clientID: self.configuration.clientID),
                authorizationBehavior
            ]
        ))
    }

    // MARK: - Configuring the Tink Link Object

    /// Configure shared instance with configration description.
    ///
    /// Here's how you could configure Tink with a `Tink.Configuration`.
    ///
    ///     let configuration = Configuration(clientID: "<#clientID#>", redirectURI: <#URL#>)
    ///     Tink.configure(with: configuration)
    ///
    /// - Parameters:
    ///   - configuration: The configuration to be used for the shared instance.
    public static func configure(with configuration: Tink.Configuration) {
        _shared = Tink(configuration: configuration)
    }

    /// The current configuration.
    public let configuration: Configuration

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
}

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
