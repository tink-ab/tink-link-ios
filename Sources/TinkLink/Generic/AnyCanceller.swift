/// A type-erased cancellable value.
final class AnyCanceller: Cancellable {
    private let base: Cancellable

    init<C>(_ base: C) where C: Cancellable {
        self.base = base
    }

    func cancel() {
        base.cancel()
    }
}
