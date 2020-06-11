import Foundation

protocol RESTRequest {
    var path: String { get }
    var method: RESTMethod { get }
    var body: AnyEncodable? { get }
    var queryParameters: [URLQueryItem] { get }
    var contentType: RESTContentType? { get }
    var headers: [String: String] { get }

    func onResponse(_ result: Result<(data: Data, urlResponse: URLResponse), Error>)
}

struct RESTSimpleRequest: RESTRequest {
    var path: String
    var method: RESTMethod
    var body: AnyEncodable?
    var queryParameters: [URLQueryItem]
    var contentType: RESTContentType?
    var headers: [String: String] = [:]

    private var completion: ((Result<URLResponse, Error>) -> Void)

    init(path: String, method: RESTMethod, contentType: RESTContentType?, parameters: [URLQueryItem] = [], completion: @escaping ((Result<URLResponse, Error>) -> Void)) {
        let body: AnyEncodable? = nil
        self.init(path: path, method: method, body: body, contentType: contentType, parameters: parameters, completion: completion)
    }

    init<Body: Encodable>(path: String, method: RESTMethod, body: Body?, contentType: RESTContentType?, parameters: [URLQueryItem] = [], completion: @escaping ((Result<URLResponse, Error>) -> Void)) {
        self.path = path
        self.method = method
        if let body = body {
            self.body = AnyEncodable(body)
        } else {
            self.body = nil
        }
        self.contentType = contentType
        self.queryParameters = parameters
        self.completion = completion
    }

    func onResponse(_ result: Result<(data: Data, urlResponse: URLResponse), Error>) {
        do {
            let response = try result.get()
            if let errorResponse = try? JSONDecoder().decode(RESTError.self, from: response.data),
                let serviceError = ServiceError(errorResponse) {
                completion(.failure(serviceError))
            } else {
                completion(.success(response.urlResponse))
            }
        } catch {
            completion(.failure(ServiceError(error) ?? error))
        }
    }
}

struct RESTResourceRequest<T: Decodable>: RESTRequest {

    var path: String
    var method: RESTMethod
    var body: AnyEncodable?
    var queryParameters: [URLQueryItem]
    var contentType: RESTContentType?
    var headers: [String: String] = [:]
    
    private var completion: ((Result<T, Error>) -> Void)
    init(path: String, method: RESTMethod, contentType: RESTContentType?, parameters: [URLQueryItem] = [], completion: @escaping ((Result<T, Error>) -> Void)) {
        let body: AnyEncodable? = nil
        self.init(path: path, method: method, body: body, contentType: contentType, parameters: parameters, completion: completion)
    }

    init<Body: Encodable>(path: String, method: RESTMethod, body: Body?, contentType: RESTContentType?, parameters: [URLQueryItem] = [], completion: @escaping ((Result<T, Error>) -> Void)) {
        self.path = path
        self.method = method
        if let body = body {
            self.body = AnyEncodable(body)
        } else {
            self.body = nil
        }
        self.contentType = contentType
        self.queryParameters = parameters
        self.completion = completion
    }

    func onResponse(_ result: Result<(data: Data, urlResponse: URLResponse), Error>) {
        do {
            let response = try result.get()
            if let data = response.data as? T {
                completion(.success(data))
                return
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .millisecondsSince1970
            do {
                let model = try decoder.decode(T.self, from: response.data)
                completion(.success(model))
            } catch {
                let errorResponse = try decoder.decode(RESTError.self, from: response.data)
                completion(.failure(ServiceError(errorResponse) ?? error))
            }
        } catch {
            completion(.failure(ServiceError(error) ?? error))
        }
    }
}
