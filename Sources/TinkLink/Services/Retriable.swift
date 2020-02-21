/// A type that represents something that can be retried.
public protocol Retriable {
    func retry()
}
