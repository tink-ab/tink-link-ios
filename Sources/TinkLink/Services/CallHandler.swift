import Dispatch
import GRPC
import SwiftProtobuf

final class CallHandler<Request: Message, Response: Message, Model>: Cancellable, Retriable {
    typealias Method<Request: Message, Response: Message> = (Request, CallOptions?) -> UnaryCall<Request, Response>
    typealias ResponseMap = (Response) -> Model
    typealias CallCompletionHandler<Model> = (Result<Model, Error>) -> Void

    var request: Request
    var method: Method<Request, Response>
    var responseMap: ResponseMap
    var completion: CallCompletionHandler<Model>
    private let queue: DispatchQueue

    private var backoffInSeconds: Int = 1
    private var automaticRetryCount = 0
    private var maxRetryCount = 5

    init(for request: Request, method: @escaping Method<Request, Response>, queue: DispatchQueue, responseMap: @escaping ResponseMap, completion: @escaping CallCompletionHandler<Model>) {
        self.request = request
        self.method = method
        self.queue = queue
        self.responseMap = responseMap
        self.completion = completion
        startCall()
    }

    var call: UnaryCall<Request, Response>?

    func retry() {
        _ = call?.cancel()
        startCall()
    }

    func cancel() {
        _ = call?.cancel()
    }

    private func startCall() {
        guard NetworkReachability.isConnectedToNetwork() else {
            completion(.failure(ServiceError.missingInternetConnection))
            return
        }
        let call = method(request, nil)
        self.call = call
        call.response
            .map(responseMap)
            .whenComplete { result in
                let mappedResult = result.mapError { ServiceError($0) ?? $0 }
                do {
                    let response = try mappedResult.get()
                    self.completion(.success(response))
                } catch ServiceError.unavailable(let message) {
                    guard self.automaticRetryCount < self.maxRetryCount else {
                        let error = ServiceError.unavailable(message)
                        self.completion(.failure(error))
                        return
                    }
                    self.queue.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(self.backoffInSeconds)) {
                        self.backoffInSeconds *= 2
                        self.automaticRetryCount += 1
                        self.retry()
                    }
                } catch {
                    self.completion(.failure(error))
                }
            }
    }
}
