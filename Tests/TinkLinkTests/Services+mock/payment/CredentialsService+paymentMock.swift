import Foundation
@testable import TinkCore

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
        sessionExpiryDate: Date()
    )

    func credentialsList(completion: @escaping (Result<[Credentials], Error>) -> Void) -> RetryCancellable? {
        completion(.success([credentials]))
        return nil
    }

    func credentials(id: Credentials.ID, completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable? {
        switch credentials.status {
        case .created:
            credentials = Credentials(credentials: credentials, status: .authenticating)
        case .authenticating:
            credentials = Credentials(credentials: credentials, status: .updating)
        case .updating:
            credentials = Credentials(credentials: credentials, status: .awaitingSupplementalInformation)
        case .awaitingMobileBankIDAuthentication, .awaitingThirdPartyAppAuthentication, .awaitingSupplementalInformation:
            credentials = Credentials(credentials: credentials, status: .updated)
        default:
            credentials = Credentials(credentials: credentials, status: .updated)
        }
        completion(.success(credentials))
        return nil
    }

    func createCredentials(providerID: Provider.ID, refreshableItems: RefreshableItems, fields: [String: String], appUri: URL?, completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
    }

    func deleteCredentials(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
    }

    func updateCredentials(credentialsID: Credentials.ID, providerID: Provider.ID, appUri: URL?, callbackUri: URL?, fields: [String: String], completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
    }

    func refreshCredentials(credentialsID: Credentials.ID, refreshableItems: RefreshableItems, optIn: Bool, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
    }

    func supplementInformation(credentialsID: Credentials.ID, fields: [String: String], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.success)
        return nil
    }

    func cancelSupplementInformation(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
    }

    func enableCredentials(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
    }

    func disableCredentials(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
    }

    func thirdPartyCallback(state: String, parameters: [String: String], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
    }

    func manualAuthentication(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
    }

    func qr(credentialsID: Credentials.ID, completion: @escaping (Result<Data, Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
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
        sessionExpiryDate: Date()
    )

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

    func createCredentials(providerID: Provider.ID, refreshableItems: RefreshableItems, fields: [String: String], appUri: URL?, completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
    }

    func deleteCredentials(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
    }

    func updateCredentials(credentialsID: Credentials.ID, providerID: Provider.ID, appUri: URL?, callbackUri: URL?, fields: [String: String], completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
    }

    func refreshCredentials(credentialsID: Credentials.ID, refreshableItems: RefreshableItems, optIn: Bool, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        return nil
    }

    func supplementInformation(credentialsID: Credentials.ID, fields: [String: String], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.success)
        fatalError("\(#function) should not be called")
    }

    func cancelSupplementInformation(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.unauthenticatedError))
        fatalError("\(#function) should not be called")
    }

    func enableCredentials(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.unauthenticatedError))
        fatalError("\(#function) should not be called")
    }

    func disableCredentials(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.unauthenticatedError))
        fatalError("\(#function) should not be called")
    }

    func thirdPartyCallback(state: String, parameters: [String: String], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
    }

    func manualAuthentication(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
    }

    func qr(credentialsID: Credentials.ID, completion: @escaping (Result<Data, Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
    }
}
