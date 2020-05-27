import Foundation
@testable import TinkLink

class MockedSuccessCredentialsService: CredentialsService {

    private var credentials = [Credentials]()

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
            completion(.success((credentials)))
        } else {
            fatalError()
        }
        return TestRetryCanceller { [weak self] in
            guard let self = self else { return }
            self.credentials(id: id, completion: completion)
        }
    }

    func createCredentials(providerID: Provider.ID, refreshableItems: RefreshableItems, fields: [String : String], appUri: URL?, completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable? {
        let credentialsID = String(credentials.count)
        let addedCredential = Credentials(id: .init(credentialsID), providerID: providerID, kind: .password, status: .created, statusPayload: "", statusUpdated: nil, updated: nil, fields: fields, supplementalInformationFields: [], thirdPartyAppAuthentication: nil, sessionExpiryDate: nil)
        credentials.append(addedCredential)
        completion(.success(addedCredential))
        return nil
    }

    func deleteCredentials(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        credentials.removeAll { $0.id == credentialsID }
        completion(.success(()))
        return nil
    }

    func updateCredentials(credentialsID: Credentials.ID, providerID: Provider.ID, appUri: URL?, fields: [String : String], completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable? {
        if let index = credentials.firstIndex(where: { $0.id == credentialsID }) {
            let credentialToBeUpdated = credentials[index]
            let credential = Credentials(id: credentialToBeUpdated.id, providerID: credentialToBeUpdated.providerID, kind: credentialToBeUpdated.kind, status: .updated, statusPayload: "", statusUpdated: nil, updated: nil, fields: fields, supplementalInformationFields: [], thirdPartyAppAuthentication: nil, sessionExpiryDate: nil)
            credentials[index] = credential
            completion(.success(credential))
        }
        return nil
    }

    func refreshCredentials(credentialsID: Credentials.ID, refreshableItems: RefreshableItems, optIn: Bool, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.success(()))
        return nil
    }

    @discardableResult
    func supplementInformation(credentialsID: Credentials.ID, fields: [String : String], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        if let index = credentials.firstIndex(where: { $0.id == credentialsID }) {
            let credentialToBeUpdated = credentials[index]
            let credential = Credentials(id: credentialToBeUpdated.id, providerID: credentialToBeUpdated.providerID, kind: credentialToBeUpdated.kind, status: credentialToBeUpdated.status, statusPayload: "", statusUpdated: nil, updated: nil, fields: fields, supplementalInformationFields: credentialToBeUpdated.supplementalInformationFields, thirdPartyAppAuthentication: nil, sessionExpiryDate: nil)
            credentials[index] = credential
            completion(.success(()))
        }
        return TestRetryCanceller { [weak self] in
            guard let self = self else { return }
            self.supplementInformation(credentialsID: credentialsID, fields: fields, completion: completion)
        }
    }

    func cancelSupplementInformation(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        if let index = credentials.firstIndex(where: { $0.id == credentialsID }) {
            let credentialToBeUpdated = credentials[index]
            let credential = Credentials(id: credentialToBeUpdated.id, providerID: credentialToBeUpdated.providerID, kind: credentialToBeUpdated.kind, status: .awaitingSupplementalInformation, statusPayload: "", statusUpdated: nil, updated: nil, fields: credentialToBeUpdated.fields, supplementalInformationFields: credentialToBeUpdated.supplementalInformationFields, thirdPartyAppAuthentication: nil, sessionExpiryDate: nil)
            credentials[index] = credential
            completion(.success(()))
        }
        return nil
    }

    func enableCredentials(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.success(()))
        return nil
    }

    func disableCredentials(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.success(()))
        return nil
    }

    func thirdPartyCallback(state: String, parameters: [String : String], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.success(()))
        return nil
    }

    func manualAuthentication(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.success(()))
        return nil
    }

    func qr(credentialsID: Credentials.ID, completion: @escaping (Result<Data, Error>) -> Void) -> RetryCancellable? {
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

    func createCredentials(providerID: Provider.ID, refreshableItems: RefreshableItems, fields: [String : String], appUri: URL?, completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.unauthenticatedError))
        return nil
    }

    func deleteCredentials(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.unauthenticatedError))
        return nil
    }

    func updateCredentials(credentialsID: Credentials.ID, providerID: Provider.ID, appUri: URL?, fields: [String : String], completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(ServiceError.unauthenticatedError))
        return nil
    }

    func refreshCredentials(credentialsID: Credentials.ID, refreshableItems: RefreshableItems, optIn: Bool, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        return nil
    }

    func supplementInformation(credentialsID: Credentials.ID, fields: [String : String], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
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

    func thirdPartyCallback(state: String, parameters: [String : String], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
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

class MockedSuccessCredentialsServiceForPayment: CredentialsService {
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
    // Just return updated credentials
    func credentialsList(completion: @escaping (Result<[Credentials], Error>) -> Void) -> RetryCancellable? {
        completion(.success([credentials]))
        return nil
    }

    // Just return updated credentials
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
