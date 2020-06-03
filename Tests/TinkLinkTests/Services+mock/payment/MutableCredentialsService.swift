import Foundation
@testable import TinkLink

class MutableCredentialsService: CredentialsService {
    var credentialsByID: [Credentials.ID: Credentials] = [:]

    var createCredentialsKind: Credentials.Kind = .password
    var credentialsStatusAfterUpdate: Credentials.Status = .authenticating
    var credentialsStatusAfterSupplementalInformation: Credentials.Status = .updating

    func modifyCredentials(id: Credentials.ID, status: Credentials.Status, supplementalInformationFields: [Provider.FieldSpecification] = [], thirdPartyAppAuthentication: Credentials.ThirdPartyAppAuthentication? = nil) {
        let credentials = credentialsByID[id]!

        let modifiedCredentials = Credentials(
            id: credentials.id,
            providerID: credentials.providerID,
            kind: credentials.kind,
            status: status,
            statusPayload: "",
            statusUpdated: Date(),
            updated: Date(),
            fields: credentials.fields,
            supplementalInformationFields: supplementalInformationFields,
            thirdPartyAppAuthentication: thirdPartyAppAuthentication,
            sessionExpiryDate: nil
        )

        credentialsByID[id] = modifiedCredentials
    }

    func credentialsList(completion: @escaping (Result<[Credentials], Error>) -> Void) -> RetryCancellable? {
        completion(.success(Array(credentialsByID.values)))
        return nil
    }

    func credentials(id: Credentials.ID, completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable? {
        if let credentials = credentialsByID[id] {
            completion(.success(credentials))
        } else {
            completion(.failure(ServiceError.notFound("No credentials with id: \(id.value)")))
        }
        return nil
    }

    func createCredentials(providerID: Provider.ID, refreshableItems: RefreshableItems, fields: [String : String], appUri: URL?, completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable? {
        let credentials = Credentials(
            id: Credentials.ID(UUID().uuidString),
            providerID: providerID,
            kind: createCredentialsKind,
            status: .created,
            statusPayload: "",
            statusUpdated: Date(),
            updated: nil,
            fields: fields,
            supplementalInformationFields: [],
            thirdPartyAppAuthentication: nil,
            sessionExpiryDate: nil
        )
        credentialsByID[credentials.id] = credentials
        completion(.success(credentials))
        return nil
    }

    func deleteCredentials(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        if credentialsByID[credentialsID] != nil {
            credentialsByID[credentialsID] = nil
            completion(.success)
        } else {
            completion(.failure(ServiceError.notFound("No credentials with id: \(credentialsID.value)")))
        }
        return nil
    }

    func updateCredentials(credentialsID: Credentials.ID, providerID: Provider.ID, appUri: URL?, fields: [String : String], completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable? {
        if let credentials = credentialsByID[credentialsID] {
            let updatedCredentials = Credentials(
                id: credentials.id,
                providerID: credentials.providerID,
                kind: credentials.kind,
                status: credentialsStatusAfterUpdate,
                statusPayload: "",
                statusUpdated: Date(),
                updated: Date(),
                fields: fields,
                supplementalInformationFields: [],
                thirdPartyAppAuthentication: nil,
                sessionExpiryDate: nil
            )
            credentialsByID[credentialsID] = updatedCredentials
            completion(.success(updatedCredentials))
        } else {
            completion(.failure(ServiceError.notFound("No credentials with id: \(credentialsID.value)")))
        }
        return nil
    }

    func refreshCredentials(credentialsID: Credentials.ID, refreshableItems: RefreshableItems, optIn: Bool, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
    }

    func supplementInformation(credentialsID: Credentials.ID, fields: [String : String], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        if let credentials = credentialsByID[credentialsID] {
            let updatedCredentials = Credentials(
                id: credentials.id,
                providerID: credentials.providerID,
                kind: credentials.kind,
                status: credentialsStatusAfterSupplementalInformation,
                statusPayload: "",
                statusUpdated: Date(),
                updated: Date(),
                fields: credentials.fields,
                supplementalInformationFields: [],
                thirdPartyAppAuthentication: nil,
                sessionExpiryDate: nil
            )
            credentialsByID[credentialsID] = updatedCredentials
            completion(.success)
        } else {
            completion(.failure(ServiceError.notFound("No credentials with id: \(credentialsID.value)")))
        }
        return nil
    }

    func cancelSupplementInformation(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        if let credentials = credentialsByID[credentialsID] {
            let updatedCredentials = Credentials(
                id: credentials.id,
                providerID: credentials.providerID,
                kind: credentials.kind,
                status: .authenticationError,
                statusPayload: "",
                statusUpdated: Date(),
                updated: Date(),
                fields: credentials.fields,
                supplementalInformationFields: [],
                thirdPartyAppAuthentication: nil,
                sessionExpiryDate: nil
            )
            credentialsByID[credentialsID] = updatedCredentials
            completion(.success)
        } else {
            completion(.failure(ServiceError.notFound("No credentials with id: \(credentialsID.value)")))
        }
        return nil
    }

    func enableCredentials(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        if let credentials = credentialsByID[credentialsID] {
            let updatedCredentials = Credentials(
                id: credentials.id,
                providerID: credentials.providerID,
                kind: credentials.kind,
                status: .updated,
                statusPayload: "",
                statusUpdated: Date(),
                updated: Date(),
                fields: credentials.fields,
                supplementalInformationFields: [],
                thirdPartyAppAuthentication: nil,
                sessionExpiryDate: nil
            )
            credentialsByID[credentialsID] = updatedCredentials
            completion(.success)
        } else {
            completion(.failure(ServiceError.notFound("No credentials with id: \(credentialsID.value)")))
        }
        return nil
    }

    func disableCredentials(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        if let credentials = credentialsByID[credentialsID] {
            let updatedCredentials = Credentials(
                id: credentials.id,
                providerID: credentials.providerID,
                kind: credentials.kind,
                status: .disabled,
                statusPayload: "",
                statusUpdated: Date(),
                updated: Date(),
                fields: credentials.fields,
                supplementalInformationFields: [],
                thirdPartyAppAuthentication: nil,
                sessionExpiryDate: nil
            )
            credentialsByID[credentialsID] = updatedCredentials
            completion(.success)
        } else {
            completion(.failure(ServiceError.notFound("No credentials with id: \(credentialsID.value)")))
        }
        return nil
    }

    func thirdPartyCallback(state: String, parameters: [String : String], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
    }

    func manualAuthentication(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
    }

    func qr(credentialsID: Credentials.ID, completion: @escaping (Result<Data, Error>) -> Void) -> RetryCancellable? {
        fatalError("\(#function) should not be called")
    }
}
