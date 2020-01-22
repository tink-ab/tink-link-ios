import Foundation
import GRPC
import NIO
import NIOSSL

final class Client {
    let connection: ClientConnection
    var defaultCallOptions = CallOptions()
    var restURL: URL
    var grpcURL: URL
    var restCertificateURL: URL?
    var grpcCertificateURL: URL?

    let tinkLinkName = "Tink Link iOS"
    var tinkLinkVersion: String? {
        let version = Bundle(for: Client.self).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        return version
    }

    init(environment: Environment, clientID: String, userAgent: String? = nil, grpcCertificateURL: URL? = nil, restCertificateURL: URL? = nil) {
        let eventLoopGroup = PlatformSupport.makeEventLoopGroup(loopCount: 1, networkPreference: .best)
        let target: ConnectionTarget = .hostAndPort(environment.grpcURL.host!, environment.grpcURL.port!)
        var configuration = ClientConnection.Configuration(target: target, eventLoopGroup: eventLoopGroup)

        configuration.tls = ClientConnection.Configuration.TLS()
        if let grpcCertificateURL = grpcCertificateURL {
            do {
                let certificate = try NIOSSLCertificate(file: grpcCertificateURL.path, format: .pem)
                configuration.tls?.certificateChain = [NIOSSLCertificateSource.certificate(certificate)]
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }

        self.restURL = environment.restURL
        self.grpcURL = environment.grpcURL
        self.restCertificateURL = restCertificateURL
        self.grpcCertificateURL = grpcCertificateURL

        self.connection = ClientConnection(configuration: configuration)

        defaultCallOptions.add(key: CallOptions.HeaderKey.oauthClientID.key, value: clientID)
        defaultCallOptions.add(key: CallOptions.HeaderKey.sdkName.key, value: tinkLinkName)
        if let tinkLinkVersion = tinkLinkVersion {
            defaultCallOptions.add(key: CallOptions.HeaderKey.sdkVersion.key, value: tinkLinkVersion)
        }
    }
}

extension Client {
    convenience init(configuration: TinkLink.Configuration) {
        self.init(
            environment: configuration.environment,
            clientID: configuration.clientID,
            grpcCertificateURL: configuration.grpcCertificateURL,
            restCertificateURL: configuration.restCertificateURL
        )
    }
}
