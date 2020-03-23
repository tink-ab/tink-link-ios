import Foundation

final class RESTCredentialsService {

    private let client: RESTClient

    init(client: RESTClient) {
        self.client = client
    }

    func credentials(completion: @escaping (Result<[RESTCredentials], Error>) -> Void) ->
        Cancellable? {

            let request = RESTResourceRequest<RESTCredentialsList>(path: "/api/v1/credentials/list", method: .get, contentType: .json) { result in
                let result = result.map { $0.credentials }
                completion(result)
            }

        return client.performRequest(request)
    }

    func createCredentials(providerId: String, fields: [String: String] = [:], appUri: URL?, completion: @escaping (Result<RESTCredentials, Error>) -> Void) -> Cancellable? {

        let body = RESTCreateCredentialsRequest(providerName: providerId, fields: fields, callbackUri: nil, appUri: appUri?.absoluteString, triggerRefresh: nil)
        let data = try? JSONEncoder().encode(body)
        let request = RESTResourceRequest<RESTCredentials>(path: "/api/v1/credentials", method: .post, body: data, contentType: .json, completion: completion)
        return client.performRequest(request)
    }

    func deleteCredentials(credentialsId: String, completion: @escaping (Result<Void, Error>) -> Void) -> Cancellable? {

        let request = RESTSimpleRequest(path: "/api/v1/credentials/\(credentialsId)", method: .delete, contentType: .json) { (result) in
            completion(result.map { _ in })
        }
        return client.performRequest(request)
    }

    func updateCredential(credentialsId: String, fields: [String: String] = [:], completion: @escaping (Result<RESTCredentials, Error>) -> Void) -> Cancellable? {

        let body = RESTUpdateCredentialsRequest(providerName: nil, fields: fields, callbackUri: nil, appUri: nil)
        let data = try? JSONEncoder().encode(body)
        let request = RESTResourceRequest<RESTCredentials>(path: "/api/v1/credentials/\(credentialsId)", method: .put, body: data, contentType: .json, completion: completion)
        return client.performRequest(request)
    }

    func refreshCredentials(credentialsId: String, completion: @escaping (Result<Void, Error>) -> Void) -> Cancellable? {

        let request = RESTSimpleRequest(path: "/api/v1/credentials/\(credentialsId)/refresh", method: .post, contentType: .json) { (result) in
            completion(result.map { _ in })
        }
        return client.performRequest(request)
    }

    func supplementInformation(credentialsId: String, fields: [String: String] = [:], completion: @escaping (Result<Void, Error>) -> Void) -> Cancellable? {

        let information = RESTSupplementalInformation(information: fields)
        let data = try? JSONEncoder().encode(information)
        let request = RESTSimpleRequest(path: "/api/v1/credentials/\(credentialsId)/supplemental-information", method: .post, body: data, contentType: .json) { (result) in
            completion(result.map { _ in })
        }
        return client.performRequest(request)
    }

    func cancelSupplementInformation(credentialsId: String, completion: @escaping (Result<Void, Error>) -> Void) -> Cancellable? {
        return nil
//        let request = RESTSimpleRequest(path: "/api/v1/credentials/\(credentialsId)/supplemental-information", method: .delete, contentType: .json) { (result) in
//            completion(result.map { _ in })
//        }
//        return client.performRequest(request)
    }

    func thirdPartyCallback(state: String, parameters: [String: String], completion: @escaping (Result<Void, Error>) -> Void) -> Cancellable? {

        let relayedRequest = RESTCallbackRelayedRequest(state: state, parameters: parameters)
        let data = try? JSONEncoder().encode(relayedRequest)
        let request = RESTSimpleRequest(path: "/api/v1/credentials/third-party/callback/relayed", method: .post, body: data, contentType: .json) { (result) in
            completion(result.map { _ in })
        }
        return client.performRequest(request)
    }

    func manualAuthentication(credentialsId: String, completion: @escaping (Result<Void, Error>) -> Void) -> Cancellable? {

        let request = RESTSimpleRequest(path: "/api/v1/credentials/\(credentialsId)/authenticate", method: .post, contentType: .json) { (result) in
            completion(result.map { _ in })
        }
        return client.performRequest(request)
    }
}
