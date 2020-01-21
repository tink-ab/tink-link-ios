class MultiHandler: Cancellable, Retriable {
    private var handlers: [Cancellable & Retriable] = []

    private(set) var isCancelled: Bool = false
    private(set) var hasRetried: Bool = false

    func add(_ handler: RetryCancellable?) {
        if let handler = handler {
            handlers.append(handler)
        }
    }

    func cancel() {
        isCancelled = true
        for handler in handlers {
            handler.cancel()
        }
    }

    func retry() {
        hasRetried = true
        for handler in handlers {
            handler.retry()
        }
    }
}

class MultiCanceller: Cancellable {
    private var handlers: [Cancellable] = []

    private(set) var isCancelled: Bool = false

    func add(_ handler: Cancellable?) {
        if let handler = handler {
            handlers.append(handler)
        }
    }

    func cancel() {
        isCancelled = true
        for handler in handlers {
            handler.cancel()
        }
    }
}
