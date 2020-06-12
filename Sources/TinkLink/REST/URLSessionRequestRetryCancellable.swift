import Foundation

final class URLSessionRetryCancellableTask: RetryCancellable {
    private weak var session: URLSession?
    private let urlRequest: URLRequest
    private let completionHandler: (Data?, URLResponse?, Error?) -> Void

    private var task: URLSessionTask?

    init(session: URLSession, urlRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        self.session = session
        self.urlRequest = urlRequest
        self.completionHandler = completionHandler
    }

    func start() {
        let task = session?.dataTask(with: urlRequest, completionHandler: completionHandler)
        task?.resume()
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
