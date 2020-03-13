import Foundation
import GRPC
@testable import TinkLink

class MockedSuccessCredentialService: CredentialService, TokenConfigurableService {
    var defaultCallOptions = CallOptions()

    private var credentials = [Credential]()
    
    func credentials(completion: @escaping (Result<[Credential], Error>) -> Void) -> RetryCancellable? {
        completion(.success(credentials))
        return nil
    }

    func createCredential(providerID: Provider.ID, kind: Credential.Kind, fields: [String : String], appURI: URL?, completion: @escaping (Result<Credential, Error>) -> Void) -> RetryCancellable? {
        let credentialID = String(credentials.count)
        let addedCredential = Credential(id: .init(credentialID), providerID: providerID, kind: kind, status: .created, statusPayload: "", statusUpdated: nil, updated: nil, fields: fields, supplementalInformationFields: [], thirdPartyAppAuthentication: nil, sessionExpiryDate: nil)
        credentials.append(addedCredential)
        completion(.success(addedCredential))
        return nil
    }

    func deleteCredential(credentialID: Credential.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        credentials.removeAll { $0.id == credentialID }
        completion(.success(()))
        return nil
    }

    func updateCredential(credentialID: Credential.ID, fields: [String : String], completion: @escaping (Result<Credential, Error>) -> Void) -> RetryCancellable? {
        if let index = credentials.firstIndex(where: { $0.id == credentialID }) {
            let credentialToBeUpdated = credentials[index]
            let credential = Credential(id: credentialToBeUpdated.id, providerID: credentialToBeUpdated.providerID, kind: credentialToBeUpdated.kind, status: .updated, statusPayload: "", statusUpdated: nil, updated: nil, fields: fields, supplementalInformationFields: [], thirdPartyAppAuthentication: nil, sessionExpiryDate: nil)
            credentials[index] = credential
            completion(.success(credential))
        }
        return nil
    }

    func refreshCredentials(credentialIDs: [Credential.ID], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.success(()))
        return nil
    }

    func supplementInformation(credentialID: Credential.ID, fields: [String : String], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        if let index = credentials.firstIndex(where: { $0.id == credentialID }) {
            let credentialToBeUpdated = credentials[index]
            let credential = Credential(id: credentialToBeUpdated.id, providerID: credentialToBeUpdated.providerID, kind: credentialToBeUpdated.kind, status: .updated, statusPayload: "", statusUpdated: nil, updated: nil, fields: fields, supplementalInformationFields: credentialToBeUpdated.supplementalInformationFields, thirdPartyAppAuthentication: nil, sessionExpiryDate: nil)
            credentials[index] = credential
            completion(.success(()))
        }
        return nil
    }

    func cancelSupplementInformation(credentialID: Credential.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        if let index = credentials.firstIndex(where: { $0.id == credentialID }) {
            let credentialToBeUpdated = credentials[index]
            let credential = Credential(id: credentialToBeUpdated.id, providerID: credentialToBeUpdated.providerID, kind: credentialToBeUpdated.kind, status: .awaitingSupplementalInformation, statusPayload: "", statusUpdated: nil, updated: nil, fields: credentialToBeUpdated.fields, supplementalInformationFields: credentialToBeUpdated.supplementalInformationFields, thirdPartyAppAuthentication: nil, sessionExpiryDate: nil)
            credentials[index] = credential
            completion(.success(()))
        }
        return nil
    }

    func enableCredential(credentialID: Credential.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.success(()))
        return nil
    }

    func disableCredential(credentialID: Credential.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.success(()))
        return nil
    }

    func thirdPartyCallback(state: String, parameters: [String : String], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.success(()))
        return nil
    }

    func manualAuthentication(credentialID: Credential.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.success(()))
        return nil
    }

    func qr(credentialID: Credential.ID, completion: @escaping (Result<Data, Error>) -> Void) -> RetryCancellable? {
        return nil
    }
}

class MockedUnauthenticatedErrorCredentialService: CredentialService, TokenConfigurableService {
    var defaultCallOptions = CallOptions()

    func credentials(completion: @escaping (Result<[Credential], Error>) -> Void) -> RetryCancellable? {
        completion(.failure(MockedServiceError.unauthenticatedError))
        return nil
    }

    func createCredential(providerID: Provider.ID, kind: Credential.Kind, fields: [String : String], appURI: URL?, completion: @escaping (Result<Credential, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(MockedServiceError.unauthenticatedError))
        return nil
    }

    func deleteCredential(credentialID: Credential.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(MockedServiceError.unauthenticatedError))
        return nil
    }

    func updateCredential(credentialID: Credential.ID, fields: [String : String], completion: @escaping (Result<Credential, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(MockedServiceError.unauthenticatedError))
        return nil
    }

    func refreshCredentials(credentialIDs: [Credential.ID], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        return nil
    }

    func supplementInformation(credentialID: Credential.ID, fields: [String : String], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(MockedServiceError.unauthenticatedError))
        return nil
    }

    func cancelSupplementInformation(credentialID: Credential.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(MockedServiceError.unauthenticatedError))
        return nil
    }

    func enableCredential(credentialID: Credential.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(MockedServiceError.unauthenticatedError))
        return nil
    }

    func disableCredential(credentialID: Credential.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(MockedServiceError.unauthenticatedError))
        return nil
    }

    func thirdPartyCallback(state: String, parameters: [String : String], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(MockedServiceError.unauthenticatedError))
        return nil
    }

    func manualAuthentication(credentialID: Credential.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(MockedServiceError.unauthenticatedError))
        return nil
    }

    func qr(credentialID: Credential.ID, completion: @escaping (Result<Data, Error>) -> Void) -> RetryCancellable? {
        completion(.failure(MockedServiceError.unauthenticatedError))
        return nil
    }
}
