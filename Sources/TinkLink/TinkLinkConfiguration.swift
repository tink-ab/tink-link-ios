import TinkCore
import Foundation

public struct TinkLinkConfiguration: Configuration {
    /// The client id for your app.
    public var clientID: String

    /// The URI you've setup in Console.
    public var appURI: URL?

    /// The environment to use.
    public var environment: TinkCore.Tink.Environment

    /// Certificate to use with the API.
    public var certificateURL: URL?

    public init(clientID: String, appURI: URL, environment: Tink.Environment = .production, certificateURL:URL? = nil) {
        self.clientID = clientID
        self.appURI = appURI
        self.environment = environment
        self.certificateURL = certificateURL
    }
}
