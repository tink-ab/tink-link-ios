import Foundation

final class RESTCredentialsService: CredentialsService {

    private let client: RESTClient
    private let accessToken: AccessToken

    init(client: RESTClient, accessToken: AccessToken) {
        self.client = client
        self.accessToken = accessToken
    }

    func credentials(completion: @escaping (Result<[Credentials], Error>) -> Void) -> RetryCancellable? {

        var request = RESTResourceRequest<RESTCredentialsList>(path: "/api/v1/credentials/list", method: .get, contentType: .json) { result in
            let result = result.map { $0.credentials.map(Credentials.init) }
            completion(result)
        }
        request.headers = ["Authentication" : "Bearer \(accessToken.rawValue)"]

        return client.performRequest(request)
    }

    func createCredentials(providerID: Provider.ID, kind: Credentials.Kind, fields: [String: String], appUri: URL?, completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable? {

        let body = RESTCreateCredentialsRequest(providerName: providerID.value, fields: fields, callbackUri: nil, appUri: appUri?.absoluteString, triggerRefresh: nil)
        let data = try? JSONEncoder().encode(body)

        var request = RESTResourceRequest<RESTCredentials>(path: "/api/v1/credentials", method: .post, body: data, contentType: .json) { result in
            completion(result.map(Credentials.init))
        }
        request.headers = ["Authentication" : "Bearer \(accessToken.rawValue)"]

        return client.performRequest(request)
    }

    func deleteCredentials(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {

        var request = RESTSimpleRequest(path: "/api/v1/credentials/\(credentialsID.value)", method: .delete, contentType: .json) { (result) in
            completion(result.map { _ in })
        }
        request.headers = ["Authentication" : "Bearer \(accessToken.rawValue)"]

        return client.performRequest(request)
    }

    func updateCredentials(credentialsID: Credentials.ID, fields: [String: String], completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable? {

        let body = RESTUpdateCredentialsRequest(providerName: nil, fields: fields, callbackUri: nil, appUri: nil)
        let data = try? JSONEncoder().encode(body)
        var request = RESTResourceRequest<RESTCredentials>(path: "/api/v1/credentials/\(credentialsID.value)", method: .put, body: data, contentType: .json) { result in
            completion(result.map(Credentials.init))
        }
        request.headers = ["Authentication" : "Bearer \(accessToken.rawValue)"]

        return client.performRequest(request)
    }

    func refreshCredentials(credentialsIDs: [Credentials.ID], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {

        // TODO: FIX REQUIRED HERE
        var request = RESTSimpleRequest(path: "/api/v1/credentials/\(credentialsIDs.first!.value)/refresh", method: .post, contentType: .json) { (result) in
            completion(result.map { _ in })
        }
        request.headers = ["Authentication" : "Bearer \(accessToken.rawValue)"]
        return client.performRequest(request)
    }

    func supplementInformation(credentialsID: Credentials.ID, fields: [String: String], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {

        let information = RESTSupplementalInformation(information: fields)
        let data = try? JSONEncoder().encode(information)
        var request = RESTSimpleRequest(path: "/api/v1/credentials/\(credentialsID.value)/supplemental-information", method: .post, body: data, contentType: .json) { (result) in
            completion(result.map { _ in })
        }
        request.headers = ["Authentication" : "Bearer \(accessToken.rawValue)"]
        return client.performRequest(request)
    }

    func cancelSupplementInformation(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {

        //TODO: There is no cancel in REST. Investigate
        return nil
    }

    func enableCredentials(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        //TODO
        return nil
    }
    func disableCredentials(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {
        //TODO
        return nil

    }
    func thirdPartyCallback(state: String, parameters: [String: String], completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {

        let relayedRequest = RESTCallbackRelayedRequest(state: state, parameters: parameters)
        let data = try? JSONEncoder().encode(relayedRequest)
        var request = RESTSimpleRequest(path: "/api/v1/credentials/third-party/callback/relayed", method: .post, body: data, contentType: .json) { (result) in
            completion(result.map { _ in })
        }
        request.headers = ["Authentication" : "Bearer \(accessToken.rawValue)"]
        return client.performRequest(request)
    }

    func manualAuthentication(credentialsID: Credentials.ID, completion: @escaping (Result<Void, Error>) -> Void) -> RetryCancellable? {

        var request = RESTSimpleRequest(path: "/api/v1/credentials/\(credentialsID.value)/authenticate", method: .post, contentType: .json) { (result) in
            completion(result.map { _ in })
        }
        request.headers = ["Authentication" : "Bearer \(accessToken.rawValue)"]
        return client.performRequest(request)
    }

    func qr(credentialsID: Credentials.ID, completion: @escaping (Result<Data, Error>) -> Void) -> RetryCancellable? {
        var request = RESTResourceRequest<Data>(path: "/api/v1/credentials/\(credentialsID.value)/qr", method: .get, contentType: .json, completion: completion)
        request.headers = ["Authentication" : "Bearer \(accessToken.rawValue)"]
        return client.performRequest(request)
    }
}
