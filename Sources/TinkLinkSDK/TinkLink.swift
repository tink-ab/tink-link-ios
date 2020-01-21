import Foundation
#if os(iOS)
    import UIKit
#endif

/// The `TinkLink` class encapsulates a connection to the Tink API.
///
/// By default a shared `TinkLink` instance will be used, but you can also create your own
/// instance and use that instead. This allows you to use multiple `TinkLink` instances at the
/// same time.
public class TinkLink {
    static var _shared: TinkLink?

    /// The shared `TinkLink` instance.
    ///
    /// Note: You need to configure the shared instance by calling `TinkLink.configure(with:)`
    /// before accessing the shared instance. Not doing so will cause a run-time error.
    public static var shared: TinkLink {
        guard let shared = _shared else {
            fatalError("Configure Tink Link by calling `TinkLink.configure(with:)` before accessing the shared instance")
        }
        return shared
    }

    /// The current configuration.
    public let configuration: Configuration

    private(set) lazy var client = Client(configuration: configuration)

    private init() {
        do {
            self.configuration = try Configuration(processInfo: .processInfo)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    /// Create a TinkLink instance with a custom configuration.
    /// - Parameters:
    ///   - configuration: The configuration to be used.
    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    /// Configure shared instance with configration description.
    ///
    /// Here's how you could configure TinkLink with a `TinkLink.Configuration`.
    ///
    ///     let configuration = Configuration(clientID: "<#clientID#>", redirectURI: <#URL#>, market: "<#SE#>", locale: .current)
    ///     TinkLink.configure(with: configuration)
    ///
    /// - Parameters:
    ///   - configuration: The configuration to be used for the shared instance.
    public static func configure(with configuration: TinkLink.Configuration) {
        _shared = TinkLink(configuration: configuration)
    }

    @available(iOS 9.0, *)
    public func open(_ url: URL, completion: ((Result<Void, Error>) -> Void)? = nil) -> Bool {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            (urlComponents.string?.starts(with: configuration.redirectURI.absoluteString) ?? false)
        else { return false }

        let parameters = Dictionary(grouping: urlComponents.queryItems ?? [], by: { $0.name })
            .compactMapValues { $0.first?.value }

        NotificationCenter.default.post(name: .credentialThirdPartyCallback, object: nil, userInfo: parameters)

        return true
    }
}
