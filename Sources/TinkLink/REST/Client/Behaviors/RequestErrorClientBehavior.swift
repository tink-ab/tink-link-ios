import Foundation

struct RequestErrorClientBehavior: ClientBehavior {

    private let handler: (Error) -> Void

    //TODO: This used to use a TinkError type, should probably be added here too. 
    init(handler: @escaping (Error) -> Void) {
        self.handler = handler
    }

    func afterError(error: Error) {
        handler(error)
    }
}
