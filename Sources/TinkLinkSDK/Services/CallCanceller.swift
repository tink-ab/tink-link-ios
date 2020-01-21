import GRPC
import SwiftProtobuf

final class CallCanceller<Request: Message, Response: Message>: Cancellable {
    var call: UnaryCall<Request, Response>?

    deinit {
        cancel()
    }

    func cancel() {
        _ = call?.cancel()
    }
}
