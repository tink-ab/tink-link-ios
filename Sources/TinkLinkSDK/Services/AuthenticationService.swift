import Foundation
import GRPC

final class AuthenticationService: TokenConfigurableService {
    let connection: ClientConnection
    var defaultCallOptions: CallOptions
    let restURL: URL

    private var session: URLSession
    private var sessionDelegate: URLSessionDelegate?

    var accessToken: AccessToken? {
        didSet {
            if let accessToken = accessToken {
                defaultCallOptions.addAccessToken(accessToken.rawValue)
            }
        }
    }

    convenience init(tinkLink: TinkLink = .shared, accessToken: AccessToken? = nil) {
        var defaultCallOptions = tinkLink.client.defaultCallOptions
        if let accessToken = accessToken {
            defaultCallOptions.addAccessToken(accessToken.rawValue)
        }
        let client = tinkLink.client
        self.init(
            connection: client.connection,
            defaultCallOptions: defaultCallOptions,
            restURL: client.restURL,
            certificates: client.restCertificateURL
                .flatMap { try? Data(contentsOf: $0) }
                .map { [$0] } ?? []
        )
        self.accessToken = accessToken
    }

    init(connection: ClientConnection, defaultCallOptions: CallOptions, restURL: URL, certificates: [Data]) {
        self.connection = connection
        self.defaultCallOptions = defaultCallOptions
        self.restURL = restURL
        if certificates.isEmpty {
            self.session = .shared
        } else {
            self.sessionDelegate = CertificatePinningDelegate(certificates: certificates)
            self.session = URLSession(configuration: .ephemeral, delegate: sessionDelegate, delegateQueue: nil)
        }
    }
}

extension AuthenticationService {
    func authorize(redirectURI: URL, scope: TinkLink.Scope, completion: @escaping (Result<AuthorizationResponse, Error>) -> Void) -> RetryCancellable? {
        guard let clientID = defaultCallOptions.customMetadata[CallOptions.HeaderKey.oauthClientID.key].first else {
            preconditionFailure("No client id")
        }
        guard let authorization = defaultCallOptions.customMetadata[CallOptions.HeaderKey.authorization.key].first else {
            preconditionFailure("Not authorized")
        }

        guard var urlComponents = URLComponents(url: restURL, resolvingAgainstBaseURL: false) else {
            preconditionFailure("Invalid restURL")
        }
        urlComponents.path = "/api/v1/oauth/authorize"

        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue(authorization, forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        if let sdkName = defaultCallOptions.customMetadata[CallOptions.HeaderKey.sdkName.key].first {
            urlRequest.setValue(sdkName, forHTTPHeaderField: CallOptions.HeaderKey.sdkName.key)
        }
        if let sdkVersion = defaultCallOptions.customMetadata[CallOptions.HeaderKey.sdkVersion.key].first {
            urlRequest.setValue(sdkVersion, forHTTPHeaderField: CallOptions.HeaderKey.sdkVersion.key)
        }

        do {
            let body = [
                "clientId": clientID,
                "redirectUri": redirectURI.absoluteString,
                "scope": scope.description,
            ]
            urlRequest.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error))
            return nil
        }

        let serviceRetryCanceller = URLSessionRequestRetryCancellable<AuthorizationResponse, AuthorizationError>(session: session, request: urlRequest, completion: completion)
        serviceRetryCanceller.start()

        return serviceRetryCanceller
    }
}
