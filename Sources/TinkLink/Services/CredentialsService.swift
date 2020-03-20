import Foundation
import GRPC

protocol CredentialsService {
    func credentials(completion: @escaping (Result<[Credentials], Error>) -> Void) -> RetryCancellable?
    func createCredentials(providerID: Provider.ID, kind: Credentials.Kind, fields: [String: String], appURI: URL?, completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable?
    func deleteCredentials(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable?
    func updateCredentials(credentialsID: Credentials.ID, fields: [String: String], completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable?
    func refreshCredentials(credentialsIDs: [Credentials.ID], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable?
    func supplementInformation(credentialsID: Credentials.ID, fields: [String: String], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable?
    func cancelSupplementInformation(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable?
    func enableCredentials(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable?
    func disableCredentials(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable?
    func thirdPartyCallback(state: String, parameters: [String: String], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable?
    func manualAuthentication(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable?
    func qr(credentialsID: Credentials.ID, completion: @escaping (Result<Data, Error>) -> Void) -> RetryCancellable?
}

final class TinkCredentialsService: CredentialsService, TokenConfigurableService {

    let connection: ClientConnection
    let restURL: URL
    var defaultCallOptions: CallOptions {
        didSet {
            service.defaultCallOptions = defaultCallOptions
        }
    }
    private let queue: DispatchQueue

    var accessToken: AccessToken? {
        didSet {
            if let accessToken = accessToken {
                defaultCallOptions.addAccessToken(accessToken.rawValue)
            }
        }
    }

    private var session: URLSession
    private var sessionDelegate: URLSessionDelegate?

    convenience init(tink: Tink = .shared, accessToken: AccessToken? = nil) {
        var defaultCallOptions = tink.client.defaultCallOptions
        if let accessToken = accessToken {
            defaultCallOptions.addAccessToken(accessToken.rawValue)
        }
        let client = tink.client
        self.init(
            connection: client.connection,
            defaultCallOptions: defaultCallOptions,
            queue: client.queue,
            restURL: client.restURL,
            certificates: client.restCertificateURL
                .flatMap { try? Data(contentsOf: $0) }
                .map { [$0] } ?? []
        )
        self.accessToken = accessToken
    }

    init(connection: ClientConnection, defaultCallOptions: CallOptions, queue: DispatchQueue, restURL: URL, certificates: [Data]) {
        self.connection = connection
        self.defaultCallOptions = defaultCallOptions
        self.queue = queue
        self.restURL = restURL
        if certificates.isEmpty {
            self.session = .shared
        } else {
            self.sessionDelegate = CertificatePinningDelegate(certificates: certificates)
            self.session = URLSession(configuration: .ephemeral, delegate: sessionDelegate, delegateQueue: nil)
        }
    }

    internal lazy var service = CredentialServiceServiceClient(connection: connection, defaultCallOptions: defaultCallOptions)

    func credentials(completion: @escaping (Result<[Credentials], Error>) -> Void) -> RetryCancellable? {
        let request = GRPCListCredentialsRequest()

        return CallHandler(for: request, method: service.listCredentials, queue: queue, responseMap: { $0.credentials.map(Credentials.init(grpcCredential:)) }, completion: completion)
    }

    func createCredentials(providerID: Provider.ID, kind: Credentials.Kind, fields: [String: String], appURI: URL?, completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable? {
        var request = GRPCCreateCredentialRequest()
        request.providerName = providerID.value
        request.type = kind.grpcCredentialType
        request.fields = fields
        if let appURI = appURI {
            request.appUri = appURI.absoluteString
        }

        return CallHandler(for: request, method: service.createCredential, queue: queue, responseMap: { Credentials(grpcCredential: $0.credential) }, completion: { result in
            completion(result.mapError({ ServiceError($0) ?? $0 }))
        })
    }

    func deleteCredentials(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        var request = GRPCDeleteCredentialRequest()
        request.credentialID = credentialsID.value

        return CallHandler(for: request, method: service.deleteCredential, queue: queue, responseMap: { _ in }, completion: { result in
            completion(result.mapError({ ServiceError($0) ?? $0 }))
        })
    }

    func updateCredentials(credentialsID: Credentials.ID, fields: [String: String], completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable? {
        var request = GRPCUpdateCredentialRequest()
        request.credentialID = credentialsID.value
        request.fields = fields

        return CallHandler(for: request, method: service.updateCredential, queue: queue, responseMap: { Credentials(grpcCredential: $0.credential) }, completion: { result in
            completion(result.mapError({ ServiceError($0) ?? $0 }))
        })
    }

    func refreshCredentials(credentialsIDs: [Credentials.ID], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        var request = GRPCRefreshCredentialsRequest()
        request.credentialIds = credentialsIDs.map { $0.value }

        return CallHandler(for: request, method: service.refreshCredentials, queue: queue, responseMap: { _ in }, completion: { result in
            completion(result.mapError({ ServiceError($0) ?? $0 }))
        })
    }

    func supplementInformation(credentialsID: Credentials.ID, fields: [String: String], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        var request = GRPCSupplementInformationRequest()
        request.credentialID = credentialsID.value
        request.supplementalInformationFields = fields

        return CallHandler(for: request, method: service.supplementInformation, queue: queue, responseMap: { _ in }, completion: { result in
            completion(result.mapError({ ServiceError($0) ?? $0 }))
        })
    }

    func cancelSupplementInformation(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        var request = GRPCCancelSupplementInformationRequest()
        request.credentialID = credentialsID.value

        return CallHandler(for: request, method: service.cancelSupplementInformation, queue: queue, responseMap: { _ in }, completion: { result in
            completion(result.mapError({ ServiceError($0) ?? $0 }))
        })
    }

    func enableCredentials(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        var request = GRPCEnableCredentialRequest()
        request.credentialID = credentialsID.value

        return CallHandler(for: request, method: service.enableCredential, queue: queue, responseMap: { _ in }, completion: { result in
            completion(result.mapError({ ServiceError($0) ?? $0 }))
        })
    }

    func disableCredentials(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        var request = GRPCDisableCredentialRequest()
        request.credentialID = credentialsID.value

        return CallHandler(for: request, method: service.disableCredential, queue: queue, responseMap: { _ in }, completion: { result in
            completion(result.mapError({ ServiceError($0) ?? $0 }))
        })
    }

    func thirdPartyCallback(state: String, parameters: [String: String], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        var request = GRPCThirdPartyCallbackRequest()
        request.state = state
        request.parameters = parameters

        return CallHandler(for: request, method: service.thirdPartyCallback, queue: queue, responseMap: { _ in }, completion: { result in
            completion(result.mapError({ ServiceError($0) ?? $0 }))
        })
    }

    func manualAuthentication(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        var request = GRPCManualAuthenticationRequest()
        request.credentialIds = credentialsID.value

        return CallHandler(for: request, method: service.manualAuthentication, queue: queue, responseMap: { _ in }, completion: completion)
    }

    func qr(credentialsID: Credentials.ID, completion: @escaping (Result<Data, Error>) -> Void) -> RetryCancellable? {
        guard let authorization = defaultCallOptions.customMetadata[CallOptions.HeaderKey.authorization.key].first else {
            preconditionFailure("Not authorized")
        }
        
        guard var urlComponents = URLComponents(url: restURL, resolvingAgainstBaseURL: false) else {
            preconditionFailure("Invalid restURL")
        }

        urlComponents.path = "/api/v1/credentials/\(credentialsID.value)/qr"

        guard let url = urlComponents.url else {
            preconditionFailure("Invalid request url")
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue(authorization, forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        if let sdkName = defaultCallOptions.customMetadata[CallOptions.HeaderKey.sdkName.key].first {
            urlRequest.setValue(sdkName, forHTTPHeaderField: CallOptions.HeaderKey.sdkName.key)
        }
        if let sdkVersion = defaultCallOptions.customMetadata[CallOptions.HeaderKey.sdkVersion.key].first {
            urlRequest.setValue(sdkVersion, forHTTPHeaderField: CallOptions.HeaderKey.sdkVersion.key)
        }

        let serviceRetryCanceller = URLSessionRequestRetryCancellable<Data, AuthorizationError>(session: session, request: urlRequest, completion: completion)
        serviceRetryCanceller.start()

        return serviceRetryCanceller
    }
}
