import Foundation

extension URLSessionTask: RetryCancellable {
    public func retry() {
        //TODO
    }
}

final class RESTClient {
    let restURL: URL
    let behavior: ClientBehavior
    private let session: URLSession
    private let sessionDelegate: URLSessionDelegate?

    init(restURL: URL, certificates: String? = nil, behavior: ClientBehavior = EmptyClientBehavior()) {
        self.restURL = restURL
        self.behavior = behavior

        if let certificateData = certificates?.data(using: .utf8) {
            let certificates = [certificateData]
            self.sessionDelegate = CertificatePinningDelegate(certificates: certificates)
            self.session = URLSession(configuration: .ephemeral, delegate: sessionDelegate, delegateQueue: nil)
        } else {
            self.sessionDelegate = nil
            self.session = .shared
        }
    }

    func performRequest(_ request: RESTRequest) -> RetryCancellable? {
        var urlComponents = URLComponents(url: restURL, resolvingAgainstBaseURL: false)!
        urlComponents.path = request.path

        if !request.queryParameters.isEmpty {
            urlComponents.queryItems = []
        }

        for queryItem in request.queryParameters {
            urlComponents.queryItems?.append(URLQueryItem(name: queryItem.key, value: queryItem.value))
        }

        guard let url = urlComponents.url else {
            request.onResponse(.failure(URLError(.unknown)))
            self.behavior.afterError(error: URLError(.unknown))
            return nil
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue

        for (field, value) in behavior.headers {
            urlRequest.setValue(value, forHTTPHeaderField: field)
        }

        if let contentType = request.contentType {
            urlRequest.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        }

        urlRequest.httpBody = request.body
        
        behavior.beforeRequest(request: urlRequest)

        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                request.onResponse(.failure(error))
                self.behavior.afterError(error: error)
            } else if let data = data, let response = response as? HTTPURLResponse {
                if let error = HTTPStatusCodeError(statusCode: response.statusCode) {
                    request.onResponse(.failure(error))
                    self.behavior.afterError(error: error)
                } else {
                    request.onResponse(.success((data, response)))
                    self.behavior.afterSuccess(response: data, urlResponse: response)
                }
            } else {
                request.onResponse(.failure(URLError(.unknown)))
                self.behavior.afterError(error: URLError(.unknown))
            }
        }

        task.resume()

        return task
    }
}
