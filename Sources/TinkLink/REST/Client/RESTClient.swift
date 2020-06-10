import Foundation

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
            urlComponents.queryItems?.append(URLQueryItem(name: queryItem.name, value: queryItem.value))
        }

        guard let url = urlComponents.url else {
            request.onResponse(.failure(URLError(.unknown)))
            self.behavior.afterError(error: URLError(.unknown))
            return nil
        }

        do {
            let task = try URLSessionRetryCancellableTask(session: session, url: url, behavior: behavior, request: request)
            task.start()
            return task
        } catch {
            request.onResponse(.failure(error))
            self.behavior.afterError(error: error)
            return nil
        }

    }
}
