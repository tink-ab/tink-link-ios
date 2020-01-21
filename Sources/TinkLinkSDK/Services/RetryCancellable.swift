/// A type that represents something that can be retried and cancelled.
public typealias RetryCancellable = (Cancellable & Retriable)
