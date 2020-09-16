import Foundation
import TinkCore
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

    func create(providerID: Provider.ID, refreshableItems: RefreshableItems, fields: [String: String], appURI: URL?, callbackURI: URL?, completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
    }

    func delete(id: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
    }

    func update(id: Credentials.ID, providerID: Provider.ID, appURI: URL?, callbackURI: URL?, fields: [String: String], completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
    }

    func refresh(id: Credentials.ID, refreshableItems: RefreshableItems, optIn: Bool, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
    }

    func addSupplementalInformation(id: Credentials.ID, fields: [String: String], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.success)
        return nil
    }

    func cancelSupplementalInformation(id: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
    }

    func enable(id: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
    }

    func disable(id: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
    }

    func thirdPartyCallback(state: String, parameters: [String: String], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
    }

    func authenticate(id: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
    }

    func qrCode(id: Credentials.ID, completion: @escaping (Result<Data, Error>) -> Void) -> RetryCancellable? {
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

    func create(providerID: Provider.ID, refreshableItems: RefreshableItems, fields: [String: String], appURI: URL?, callbackURI: URL?, completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
    }

    func delete(id: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
    }

    func update(id: Credentials.ID, providerID: Provider.ID, appURI: URL?, callbackURI: URL?, fields: [String: String], completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
    }

    func refresh(id: Credentials.ID, refreshableItems: RefreshableItems, optIn: Bool, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        return nil
    }

    func addSupplementalInformation(id: Credentials.ID, fields: [String: String], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.success)
        fatalError("\(#function) should not be called")
    }

    func cancelSupplementalInformation(id: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.unauthenticatedError))
        fatalError("\(#function) should not be called")
    }

    func enable(id: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.unauthenticatedError))
        fatalError("\(#function) should not be called")
    }

    func disable(id: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.unauthenticatedError))
        fatalError("\(#function) should not be called")
    }

    func thirdPartyCallback(state: String, parameters: [String: String], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
    }

    func authenticate(id: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
    }

    func qrCode(id: Credentials.ID, completion: @escaping (Result<Data, Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
    }
}
