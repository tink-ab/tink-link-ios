import Foundation

struct ComposableClientBehavior: ClientBehavior {
    private let behaviors: [ClientBehavior]

    init(behaviors: [ClientBehavior]) {
        self.behaviors = behaviors
    }

    var headers: [String: String] {
        return behaviors.reduce([:], { result, next in
            var result = result
            for (k, v) in next.headers {
                result.updateValue(v, forKey: k)
            }
            return result
        })
    }

    func beforeRequest(request: URLRequest) {
        behaviors.forEach { $0.beforeRequest(request: request) }
    }

    func afterSuccess(response: Any?, urlResponse: URLResponse?) {
        behaviors.forEach { $0.afterSuccess(response: response, urlResponse: urlResponse) }
    }

    func afterError(error: Error) {
        behaviors.forEach { $0.afterError(error: error) }
    }
}
