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
    init(for request: Request, method: @escaping Method<Request, Response>, responseMap: @escaping ResponseMap, completion: @escaping CallCompletionHandler<Model>) {
        self.request = request
        self.method = method
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
        let call = method(request, nil)
        self.call = call
        call.response
            .map(responseMap)
            .whenComplete(completion)
    }
}
