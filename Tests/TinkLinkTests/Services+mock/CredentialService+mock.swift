import Foundation
@testable import TinkLink

class MockedSuccessCredentialsService: CredentialsService {
    var credentials = [Credentials]()

    @discardableResult
    func credentialsList(completion: @escaping (Result<[Credentials], Error>) -> Void) -> RetryCancellable? {
        credentials = credentials.map { Credentials(credentials: $0, status: $0.nextCredentialsStatus()) }
        completion(.success(credentials))
        return TestRetryCanceller { [weak self] in
            guard let self = self else { return }
            self.credentialsList(completion: completion)
        }
    }

    @discardableResult
    func credentials(id: Credentials.ID, completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable? {
        credentials = credentials.map { Credentials(credentials: $0, status: $0.nextCredentialsStatus()) }
        if let credentials = credentials.first(where: { $0.id == id }) {
            completion(.success(credentials))
        } else {
            fatalError()
        }
        return TestRetryCanceller { [weak self] in
            guard let self = self else { return }
            self.credentials(id: id, completion: completion)
        }
    }

    func createCredentials(providerID: Provider.ID, refreshableItems: RefreshableItems, fields: [String: String], appUri: URL?, completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable? {
        let addedCredential = Credentials.makeTestCredentials(
            providerID: providerID,
            kind: .password,
            status: .created,
            fields: fields
        )
        credentials.append(addedCredential)
        completion(.success(addedCredential))
        return nil
    }

    func deleteCredentials(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        credentials.removeAll { $0.id == credentialsID }
        completion(.success)
        return nil
    }

    func updateCredentials(credentialsID: Credentials.ID, providerID: Provider.ID, appUri: URL?, callbackUri: URL?, fields: [String: String], completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable? {
        if let index = credentials.firstIndex(where: { $0.id == credentialsID }) {
            credentials[index].modify(fields: fields, status: .updated)
            completion(.success(credentials[index]))
        }
        return nil
    }

    func refreshCredentials(credentialsID: Credentials.ID, refreshableItems: RefreshableItems, optIn: Bool, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.success)
        return nil
    }

    @discardableResult
    func supplementInformation(credentialsID: Credentials.ID, fields: [String: String], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        if let index = credentials.firstIndex(where: { $0.id == credentialsID }) {
            credentials[index].modify(supplementalInformationFields: [], status: .awaitingSupplementalInformation)
            completion(.success)
        }
        return TestRetryCanceller { [weak self] in
            guard let self = self else { return }
            self.supplementInformation(credentialsID: credentialsID, fields: fields, completion: completion)
        }
    }

    func cancelSupplementInformation(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        if let index = credentials.firstIndex(where: { $0.id == credentialsID }) {
            credentials[index].modify(supplementalInformationFields: [], status: .authenticationError)
            completion(.success)
        }
        return nil
    }

    func enableCredentials(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.success)
        return nil
    }

    func disableCredentials(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.success)
        return nil
    }

    func thirdPartyCallback(state: String, parameters: [String: String], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.success)
        return nil
    }

    func manualAuthentication(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.success)
        return nil
    }

    func qr(credentialsID: Credentials.ID, completion: @escaping (Result<Data, Error>) -> Void) -> RetryCancellable? {
        return nil
    }
}

class MockedSuccessThirdPartyAuthenticationCredentialsService: MockedSuccessCredentialsService {
    override func createCredentials(providerID: Provider.ID, refreshableItems: RefreshableItems, fields: [String: String], appUri: URL?, completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable? {
        let addedCredential = Credentials.makeTestCredentials(
            providerID: providerID,
            kind: .thirdPartyAuthentication,
            status: .created,
            fields: fields
        )
        credentials.append(addedCredential)
        completion(.success(addedCredential))
        return nil
    }
}

class MockedUnauthenticatedErrorCredentialsService: CredentialsService {
    func credentialsList(completion: @escaping (Result<[Credentials], Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.unauthenticatedError))
        return nil
    }

    func credentials(id: Credentials.ID, completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.unauthenticatedError))
        return nil
    }

    func createCredentials(providerID: Provider.ID, refreshableItems: RefreshableItems, fields: [String: String], appUri: URL?, completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.unauthenticatedError))
        return nil
    }

    func deleteCredentials(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.unauthenticatedError))
        return nil
    }

    func updateCredentials(credentialsID: Credentials.ID, providerID: Provider.ID, appUri: URL?, callbackUri: URL?, fields: [String: String], completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.unauthenticatedError))
        return nil
    }

    func refreshCredentials(credentialsID: Credentials.ID, refreshableItems: RefreshableItems, optIn: Bool, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        return nil
    }

    func supplementInformation(credentialsID: Credentials.ID, fields: [String: String], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.unauthenticatedError))
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

    func thirdPartyCallback(state: String, parameters: [String: String], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.unauthenticatedError))
        return nil
    }

    func manualAuthentication(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.unauthenticatedError))
        return nil
    }

    func qr(credentialsID: Credentials.ID, completion: @escaping (Result<Data, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.unauthenticatedError))
        return nil
    }
}
