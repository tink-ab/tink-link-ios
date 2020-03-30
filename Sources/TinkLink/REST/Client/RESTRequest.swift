import Foundation

protocol RESTRequest {
    var path: String { get }
    var method: RESTMethod { get }
    var body: Data? { get }
    var queryParameters: [String: String] { get }
    var contentType: RESTContentType? { get }
    var headers: [String: String] { get }

    func onResponse(_ result: Result<(data: Data, urlResponse: URLResponse), Error>)
}

struct RESTSimpleRequest: RESTRequest {
    var path: String
    var method: RESTMethod
    var body: Data?
    var queryParameters: [String: String]
    var contentType: RESTContentType?
    var headers: [String: String] = [:]

    private var completion: ((Result<URLResponse, Error>) -> Void)

    init(path: String, method: RESTMethod, body: Data? = nil, contentType: RESTContentType?, parameters: [String: String] = [:], completion: @escaping ((Result<URLResponse, Error>) -> Void)) {
        self.path = path
        self.method = method
        self.body = body
        self.contentType = contentType
        self.queryParameters = parameters
        self.completion = completion
    }

    func onResponse(_ result: Result<(data: Data, urlResponse: URLResponse), Error>) {
        do {
            let response = try result.get()
            completion(.success(response.urlResponse))
        } catch {
            completion(.failure(ServiceError(error) ?? error))
        }
    }
}

struct RESTResourceRequest<T: Decodable>: RESTRequest {

    var path: String
    var method: RESTMethod
    var body: Data?
    var queryParameters: [String: String]
    var contentType: RESTContentType?
    var headers: [String: String] = [:]
    
    private var completion: ((Result<T, Error>) -> Void)

    init(path: String, method: RESTMethod, body: Data? = nil, contentType: RESTContentType?, parameters: [String: String] = [:], completion: @escaping ((Result<T, Error>) -> Void)) {
        self.path = path
        self.method = method
        self.body = body
        self.contentType = contentType
        self.queryParameters = parameters
        self.completion = completion
    }

    func onResponse(_ result: Result<(data: Data, urlResponse: URLResponse), Error>) {
        do {
            let response = try result.get()
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .millisecondsSince1970
            let model = try decoder.decode(T.self, from: response.data)
            completion(.success(model))
        } catch {
            completion(.failure(ServiceError(error) ?? error))
        }
    }
}
