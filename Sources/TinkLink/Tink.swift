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

    private(set) lazy var client = Client(configuration: configuration)

    // Rest stuff 
    private var authorizationBehavior = AuthorizationHeaderClientBehavior(sessionCredential: nil)

    private(set) lazy var restClient: RESTClient = {
        let certificateURL = self.configuration.restCertificateURL
        let certificate = certificateURL.flatMap { try? String(contentsOf: $0, encoding: .utf8) }
        return RESTClient(restURL: self.configuration.environment.restURL, certificates: certificate, behavior: ComposableClientBehavior(
            behaviors: [
                SDKHeaderClientBehavior(sdkName: "Tink AIS iOS"),
                authorizationBehavior
            ]
        ))
    }()

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

    private init() {
        do {
            self.configuration = try Configuration(processInfo: .processInfo)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    /// Create a Tink instance with a custom configuration.
    /// - Parameters:
    ///   - configuration: The configuration to be used.
    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    // MARK: - Configuring the Tink Link Object

    /// Configure shared instance with configration description.
    ///
    /// Here's how you could configure Tink with a `Tink.Configuration`.
    ///
    ///     let configuration = Configuration(clientID: "<#clientID#>", redirectURI: <#URL#>, market: "<#SE#>", locale: .current)
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

        let parameters = Dictionary(grouping: urlComponents.queryItems ?? [], by: { $0.name })
            .compactMapValues { $0.first?.value }

        NotificationCenter.default.post(name: .credentialThirdPartyCallback, object: nil, userInfo: parameters)

        return true
    }
}
