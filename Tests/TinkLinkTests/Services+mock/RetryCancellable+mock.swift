@testable import TinkLink

struct TestRetryCanceller: RetryCancellable {
    var retryBlock: () -> Void
    init(_ block: @escaping () -> Void) {
        self.retryBlock = block
    }

    func retry() {
        retryBlock()
    }

    func cancel() {}
}
