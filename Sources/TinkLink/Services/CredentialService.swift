import Foundation
import GRPC

final class CredentialService: TokenConfigurableService {
    let connection: ClientConnection
    var defaultCallOptions: CallOptions {
        didSet {
            service.defaultCallOptions = defaultCallOptions
        }
    }

    var accessToken: AccessToken? {
        didSet {
            if let accessToken = accessToken {
                defaultCallOptions.addAccessToken(accessToken.rawValue)
            }
        }
    }

    convenience init(tink: Tink = .shared, accessToken: AccessToken? = nil) {
        var defaultCallOptions = tink.client.defaultCallOptions
        if let accessToken = accessToken {
            defaultCallOptions.addAccessToken(accessToken.rawValue)
        }
        self.init(connection: tink.client.connection, defaultCallOptions: defaultCallOptions)
        self.accessToken = accessToken
    }

    init(connection: ClientConnection, defaultCallOptions: CallOptions) {
        self.connection = connection
        self.defaultCallOptions = defaultCallOptions
    }

    internal lazy var service = CredentialServiceServiceClient(connection: connection, defaultCallOptions: defaultCallOptions)

    func credentials(completion: @escaping (Result<[Credentials], Error>) -> Void) -> RetryCancellable {
        let request = GRPCListCredentialsRequest()

        return CallHandler(for: request, method: service.listCredentials, responseMap: { $0.credentials.map(Credentials.init(grpcCredential:)) }, completion: completion)
    }

    func createCredential(providerID: Provider.ID, kind: Credentials.Kind = .unknown, fields: [String: String] = [:], appURI: URL?, completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable {
        var request = GRPCCreateCredentialRequest()
        request.providerName = providerID.value
        request.type = kind.grpcCredentialType
        request.fields = fields
        if let appURI = appURI {
            request.appUri = appURI.absoluteString
        }

        return CallHandler(for: request, method: service.createCredential, responseMap: { Credentials(grpcCredential: $0.credential) }, completion: { result in
            completion(result.mapError({ ServiceError($0) ?? $0 }))
        })
    }

    func deleteCredential(credentialID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable {
        var request = GRPCDeleteCredentialRequest()
        request.credentialID = credentialID.value

        return CallHandler(for: request, method: service.deleteCredential, responseMap: { _ in }, completion: { result in
            completion(result.mapError({ ServiceError($0) ?? $0 }))
        })
    }

    func updateCredential(credentialID: Credentials.ID, fields: [String: String] = [:], completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable {
        var request = GRPCUpdateCredentialRequest()
        request.credentialID = credentialID.value
        request.fields = fields

        return CallHandler(for: request, method: service.updateCredential, responseMap: { Credentials(grpcCredential: $0.credential) }, completion: { result in
            completion(result.mapError({ ServiceError($0) ?? $0 }))
        })
    }

    func refreshCredentials(credentialIDs: [Credentials.ID], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable {
        var request = GRPCRefreshCredentialsRequest()
        request.credentialIds = credentialIDs.map { $0.value }

        return CallHandler(for: request, method: service.refreshCredentials, responseMap: { _ in }, completion: { result in
            completion(result.mapError({ ServiceError($0) ?? $0 }))
        })
    }

    func supplementInformation(credentialID: Credentials.ID, fields: [String: String] = [:], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable {
        var request = GRPCSupplementInformationRequest()
        request.credentialID = credentialID.value
        request.supplementalInformationFields = fields

        return CallHandler(for: request, method: service.supplementInformation, responseMap: { _ in }, completion: { result in
            completion(result.mapError({ ServiceError($0) ?? $0 }))
        })
    }

    func cancelSupplementInformation(credentialID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable {
        var request = GRPCCancelSupplementInformationRequest()
        request.credentialID = credentialID.value

        return CallHandler(for: request, method: service.cancelSupplementInformation, responseMap: { _ in }, completion: { result in
            completion(result.mapError({ ServiceError($0) ?? $0 }))
        })
    }

    func enableCredential(credentialID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable {
        var request = GRPCEnableCredentialRequest()
        request.credentialID = credentialID.value

        return CallHandler(for: request, method: service.enableCredential, responseMap: { _ in }, completion: { result in
            completion(result.mapError({ ServiceError($0) ?? $0 }))
        })
    }

    func disableCredential(credentialID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable {
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

    func manualAuthentication(credentialID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable {
        var request = GRPCManualAuthenticationRequest()
        request.credentialIds = credentialID.value

        return CallHandler(for: request, method: service.manualAuthentication, responseMap: { _ in }, completion: completion)
    }
}
