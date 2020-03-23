import Foundation

protocol ClientBehavior {
    var headers: [String: String] { get }

    func beforeRequest(request: URLRequest)
    func afterSuccess(response: Any?, urlResponse: URLResponse?)
    func afterError(error: Error)
}

extension ClientBehavior {
    var headers: [String: String] { return [:] }

    func beforeRequest(request: URLRequest) { }
    func afterSuccess(response: Any?, urlResponse: URLResponse?) { }
    func afterError(error: Error) { }
}
