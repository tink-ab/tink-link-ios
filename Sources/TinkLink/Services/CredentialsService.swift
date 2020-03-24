import Foundation
import GRPC

final class CredentialsService: TokenConfigurableService {
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

    func credentials(completion: @escaping (Result<[Credentials], Error>) -> Void) -> RetryCancellable {
        let request = GRPCListCredentialsRequest()

        return CallHandler(for: request, method: service.listCredentials, queue: queue, responseMap: { $0.credentials.map(Credentials.init(grpcCredential:)) }, completion: completion)
    }

    func createCredential(providerID: Provider.ID, kind: Credentials.Kind = .unknown, fields: [String: String] = [:], appURI: URL?, completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable {
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

    func deleteCredential(credentialID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable {
        var request = GRPCDeleteCredentialRequest()
        request.credentialID = credentialID.value

        return CallHandler(for: request, method: service.deleteCredential, queue: queue, responseMap: { _ in }, completion: { result in
            completion(result.mapError({ ServiceError($0) ?? $0 }))
        })
    }

    func updateCredential(credentialID: Credentials.ID, fields: [String: String] = [:], completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable {
        var request = GRPCUpdateCredentialRequest()
        request.credentialID = credentialID.value
        request.fields = fields

        return CallHandler(for: request, method: service.updateCredential, queue: queue, responseMap: { Credentials(grpcCredential: $0.credential) }, completion: { result in
            completion(result.mapError({ ServiceError($0) ?? $0 }))
        })
    }

    func refreshCredentials(credentialIDs: [Credentials.ID], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable {
        var request = GRPCRefreshCredentialsRequest()
        request.credentialIds = credentialIDs.map { $0.value }

        return CallHandler(for: request, method: service.refreshCredentials, queue: queue, responseMap: { _ in }, completion: { result in
            completion(result.mapError({ ServiceError($0) ?? $0 }))
        })
    }

    func supplementInformation(credentialID: Credentials.ID, fields: [String: String] = [:], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable {
        var request = GRPCSupplementInformationRequest()
        request.credentialID = credentialID.value
        request.supplementalInformationFields = fields

        return CallHandler(for: request, method: service.supplementInformation, queue: queue, responseMap: { _ in }, completion: { result in
            completion(result.mapError({ ServiceError($0) ?? $0 }))
        })
    }

    func cancelSupplementInformation(credentialID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable {
        var request = GRPCCancelSupplementInformationRequest()
        request.credentialID = credentialID.value

        return CallHandler(for: request, method: service.cancelSupplementInformation, queue: queue, responseMap: { _ in }, completion: { result in
            completion(result.mapError({ ServiceError($0) ?? $0 }))
        })
    }

    func enableCredential(credentialID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable {
        var request = GRPCEnableCredentialRequest()
        request.credentialID = credentialID.value

        return CallHandler(for: request, method: service.enableCredential, queue: queue, responseMap: { _ in }, completion: { result in
            completion(result.mapError({ ServiceError($0) ?? $0 }))
        })
    }

    func disableCredential(credentialID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable {
        var request = GRPCDisableCredentialRequest()
        request.credentialID = credentialID.value

        return CallHandler(for: request, method: service.disableCredential, queue: queue, responseMap: { _ in }, completion: { result in
            completion(result.mapError({ ServiceError($0) ?? $0 }))
        })
    }

    func thirdPartyCallback(state: String, parameters: [String: String], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable {
        var request = GRPCThirdPartyCallbackRequest()
        request.state = state
        request.parameters = parameters

        return CallHandler(for: request, method: service.thirdPartyCallback, queue: queue, responseMap: { _ in }, completion: { result in
            completion(result.mapError({ ServiceError($0) ?? $0 }))
        })
    }

    func manualAuthentication(credentialID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable {
        var request = GRPCManualAuthenticationRequest()
        request.credentialIds = credentialID.value

        return CallHandler(for: request, method: service.manualAuthentication, queue: queue, responseMap: { _ in }, completion: completion)
    }
}
