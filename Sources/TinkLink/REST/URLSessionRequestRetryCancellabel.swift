import Foundation

class URLSessionRetryCancellableTask: RetryCancellable {
    private let session: URLSession
    private let urlRequest: URLRequest
    private let behavior: ClientBehavior
    private let request: RESTRequest

    private var task: URLSessionTask?

    init(session: URLSession, url: URL, behavior: ClientBehavior, request: RESTRequest) {
        self.session = session
        self.request = request
        self.behavior = behavior

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue

        for (field, value) in behavior.headers {
            urlRequest.setValue(value, forHTTPHeaderField: field)
        }

        if let contentType = request.contentType {
            urlRequest.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        }

        urlRequest.httpBody = request.body
        for header in request.headers {
            urlRequest.addValue(header.value, forHTTPHeaderField: header.key)
        }

        self.urlRequest = urlRequest
    }

    func start() {
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                self.request.onResponse(.failure(error))
                self.behavior.afterError(error: error)
            } else if let data = data, let response = response as? HTTPURLResponse {
                if let error = RESTError(statusCode: response.statusCode) {
                    self.request.onResponse(.failure(error))
                    self.behavior.afterError(error: error)
                } else {
                    self.request.onResponse(.success((data, response)))
                    self.behavior.afterSuccess(response: data, urlResponse: response)
                }
            } else {
                self.request.onResponse(.failure(URLError(.unknown)))
                self.behavior.afterError(error: URLError(.unknown))
            }
        }

        task.resume()
        self.task = task
    }

    // MARK: - Cancellable

    func cancel() {
        task?.cancel()
    }

    // MARK: - Retriable

    func retry() {
        start()
    }
}
