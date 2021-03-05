import TinkCore
import Foundation

public struct TinkLinkConfiguration: Configuration {
    /// The client id for your app.
    public var clientID: String

    /// The URI you've setup in Console.
    public var appURI: URL?

    /// The URI for redirect call back.
    public var callbackURI: URL?

    /// The environment to use.
    public var environment: TinkCore.Tink.Environment

    /// Certificate to use with the API.
    public var certificateURL: URL?

    public init(clientID: String, appURI: URL, callbackURI: URL? = nil, environment: Tink.Environment = .production, certificateURL: URL? = nil) {
        precondition(!(appURI.host?.isEmpty ?? true), "Cannot find host in the appURI")
        self.clientID = clientID
        self.appURI = appURI
        self.callbackURI = callbackURI
        self.environment = environment
        self.certificateURL = certificateURL
    }
}
