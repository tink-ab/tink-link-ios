import Foundation
import GRPC

final class CredentialService: TokenConfigurableService {
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

    func credentials(completion: @escaping (Result<[Credential], Error>) -> Void) -> RetryCancellable {
        let request = GRPCListCredentialsRequest()

        return CallHandler(for: request, method: service.listCredentials, responseMap: { $0.credentials.map(Credential.init(grpcCredential:)) }, completion: completion)
    }

    func createCredential(providerID: Provider.ID, kind: Credential.Kind = .unknown, fields: [String: String] = [:], appURI: URL?, completion: @escaping (Result<Credential, Error>) -> Void) -> RetryCancellable {
        var request = GRPCCreateCredentialRequest()
        request.providerName = providerID.value
        request.type = kind.grpcCredentialType
        request.fields = fields
        if let appURI = appURI {
            request.appUri = appURI.absoluteString
        }

        return CallHandler(for: request, method: service.createCredential, responseMap: { Credential(grpcCredential: $0.credential) }, completion: { result in
            completion(result.mapError({ ServiceError($0) ?? $0 }))
        })
    }

    func deleteCredential(credentialID: Credential.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable {
        var request = GRPCDeleteCredentialRequest()
        request.credentialID = credentialID.value

        return CallHandler(for: request, method: service.deleteCredential, responseMap: { _ in }, completion: { result in
            completion(result.mapError({ ServiceError($0) ?? $0 }))
        })
    }

    func updateCredential(credentialID: Credential.ID, fields: [String: String] = [:], completion: @escaping (Result<Credential, Error>) -> Void) -> RetryCancellable {
        var request = GRPCUpdateCredentialRequest()
        request.credentialID = credentialID.value
        request.fields = fields

        return CallHandler(for: request, method: service.updateCredential, responseMap: { Credential(grpcCredential: $0.credential) }, completion: { result in
            completion(result.mapError({ ServiceError($0) ?? $0 }))
        })
    }

    func refreshCredentials(credentialIDs: [Credential.ID], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable {
        var request = GRPCRefreshCredentialsRequest()
        request.credentialIds = credentialIDs.map { $0.value }

        return CallHandler(for: request, method: service.refreshCredentials, responseMap: { _ in }, completion: { result in
            completion(result.mapError({ ServiceError($0) ?? $0 }))
        })
    }

    func supplementInformation(credentialID: Credential.ID, fields: [String: String] = [:], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable {
        var request = GRPCSupplementInformationRequest()
        request.credentialID = credentialID.value
        request.supplementalInformationFields = fields

        return CallHandler(for: request, method: service.supplementInformation, responseMap: { _ in }, completion: { result in
            completion(result.mapError({ ServiceError($0) ?? $0 }))
        })
    }

    func cancelSupplementInformation(credentialID: Credential.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable {
        var request = GRPCCancelSupplementInformationRequest()
        request.credentialID = credentialID.value

        return CallHandler(for: request, method: service.cancelSupplementInformation, responseMap: { _ in }, completion: { result in
            completion(result.mapError({ ServiceError($0) ?? $0 }))
        })
    }

    func enableCredential(credentialID: Credential.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable {
        var request = GRPCEnableCredentialRequest()
        request.credentialID = credentialID.value

        return CallHandler(for: request, method: service.enableCredential, responseMap: { _ in }, completion: { result in
            completion(result.mapError({ ServiceError($0) ?? $0 }))
        })
    }

    func disableCredential(credentialID: Credential.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable {
        var request = GRPCDisableCredentialRequest()
        request.credentialID = credentialID.value

        return CallHandler(for: request, method: service.disableCredential, responseMap: { _ in }, completion: { result in
            completion(result.mapError({ ServiceError($0) ?? $0 }))
        })
    }

    func thirdPartyCallback(state: String, parameters: [String: String], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable {
        var request = GRPCThirdPartyCallbackRequest()
        request.state = state
        request.parameters = parameters

        return CallHandler(for: request, method: service.thirdPartyCallback, responseMap: { _ in }, completion: { result in
            completion(result.mapError({ ServiceError($0) ?? $0 }))
        })
    }

    func manualAuthentication(credentialID: Credential.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable {
        var request = GRPCManualAuthenticationRequest()
        request.credentialIds = credentialID.value

        return CallHandler(for: request, method: service.manualAuthentication, responseMap: { _ in }, completion: completion)
    }

    func qr(credentialID: Credential.ID, completion: @escaping (Result<Data, Error>) -> Void) -> RetryCancellable? {
        guard let authorization = defaultCallOptions.customMetadata[CallOptions.HeaderKey.authorization.key].first else {
            preconditionFailure("Not authorized")
        }
        
        guard var urlComponents = URLComponents(url: restURL, resolvingAgainstBaseURL: false) else {
            preconditionFailure("Invalid restURL")
        }

        urlComponents.path = "/api/v1/credentials/\(credentialID.value)/qr"

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
