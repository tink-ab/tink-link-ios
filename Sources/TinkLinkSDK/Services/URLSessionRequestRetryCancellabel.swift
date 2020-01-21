import Foundation

class URLSessionRequestRetryCancellable<T: Decodable, E: Decodable & Error>: RetryCancellable {
    private var session: URLSession
    private let request: URLRequest
    private var task: URLSessionTask?
    private var currentTask: URLSessionTask?
    private var completion: (Result<T, Error>) -> Void

    init(session: URLSession, request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
        self.session = session
        self.request = request
        self.completion = completion
    }

    func start() {
        let task = session.dataTask(with: request) { [completion] data, _, error in
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decodedResponse))
                } catch {
                    let decodedError = try? JSONDecoder().decode(E.self, from: data)
                    completion(.failure(decodedError ?? error))
                }
            } else if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(URLError(.unknown)))
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
