import Foundation
@testable import TinkLink

class MockedSuccessPaymentCredentialsService: CredentialsService {
    var credentials = Credentials(
        id: Credentials.ID("test"),
        providerID: Provider.ID("test"),
        kind: .password,
        status: .created,
        statusPayload: "",
        statusUpdated: nil,
        updated: Date(),
        fields: [:],
        supplementalInformationFields: [],
        thirdPartyAppAuthentication: nil,
        sessionExpiryDate: Date())

    func credentialsList(completion: @escaping (Result<[Credentials], Error>) -> Void) -> RetryCancellable? {
        completion(.success([credentials]))
        return nil
    }

    func credentials(id: Credentials.ID, completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable? {
        switch credentials.status {
        case .created:
            credentials = Credentials(credentials: credentials, status: .authenticating)
        case .authenticating:
            credentials = Credentials(credentials: credentials, status: .awaitingSupplementalInformation)
        case .awaitingMobileBankIDAuthentication, .awaitingThirdPartyAppAuthentication, .awaitingSupplementalInformation:
            credentials = Credentials(credentials: credentials, status: .updating)
        default:
            credentials = Credentials(credentials: credentials, status: .updated)
        }
        completion(.success(credentials))
        return nil
    }

    func createCredentials(providerID: Provider.ID, refreshableItems: RefreshableItems, fields: [String : String], appUri: URL?, completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable? {
        return nil
    }

    func deleteCredentials(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        return nil
    }

    func updateCredentials(credentialsID: Credentials.ID, providerID: Provider.ID, appUri: URL?, fields: [String : String], completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable? {
        return nil
    }

    func refreshCredentials(credentialsID: Credentials.ID, refreshableItems: RefreshableItems, optIn: Bool, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        return nil
    }

    func supplementInformation(credentialsID: Credentials.ID, fields: [String : String], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.success)
        return nil
    }

    func cancelSupplementInformation(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.unauthenticatedError))
        return nil
    }

    func enableCredentials(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.unauthenticatedError))
        return nil
    }

    func disableCredentials(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.unauthenticatedError))
        return nil
    }

    func thirdPartyCallback(state: String, parameters: [String : String], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        return nil
    }

    func manualAuthentication(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        return nil
    }

    func qr(credentialsID: Credentials.ID, completion: @escaping (Result<Data, Error>) -> Void) -> RetryCancellable? {
        return nil
    }
}

class MockedAuthenticationErrorCredentialsService: CredentialsService {
    var credentials = Credentials(
        id: Credentials.ID("test"),
        providerID: Provider.ID("test"),
        kind: .password,
        status: .created,
        statusPayload: "",
        statusUpdated: nil,
        updated: Date(),
        fields: [:],
        supplementalInformationFields: [],
        thirdPartyAppAuthentication: nil,
        sessionExpiryDate: Date())

    func credentialsList(completion: @escaping (Result<[Credentials], Error>) -> Void) -> RetryCancellable? {
        completion(.success([credentials]))
        return nil
    }

    func credentials(id: Credentials.ID, completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable? {
        switch credentials.status {
        case .created:
            credentials = Credentials(credentials: credentials, status: .authenticating)
        default:
            credentials = Credentials(credentials: credentials, status: .authenticationError)
        }
        completion(.success(credentials))
        return nil
    }

    func createCredentials(providerID: Provider.ID, refreshableItems: RefreshableItems, fields: [String : String], appUri: URL?, completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable? {
        return nil
    }

    func deleteCredentials(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        return nil
    }

    func updateCredentials(credentialsID: Credentials.ID, providerID: Provider.ID, appUri: URL?, fields: [String : String], completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable? {
        return nil
    }

    func refreshCredentials(credentialsID: Credentials.ID, refreshableItems: RefreshableItems, optIn: Bool, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        return nil
    }

    func supplementInformation(credentialsID: Credentials.ID, fields: [String : String], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.success)
        return nil
    }

    func cancelSupplementInformation(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.unauthenticatedError))
        return nil
    }

    func enableCredentials(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.unauthenticatedError))
        return nil
    }

    func disableCredentials(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.unauthenticatedError))
        return nil
    }

    func thirdPartyCallback(state: String, parameters: [String : String], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        return nil
    }

    func manualAuthentication(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        return nil
    }

    func qr(credentialsID: Credentials.ID, completion: @escaping (Result<Data, Error>) -> Void) -> RetryCancellable? {
        return nil
    }
}

