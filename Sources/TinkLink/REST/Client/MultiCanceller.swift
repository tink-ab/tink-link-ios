final class MultiCanceller: Cancellable {
    private var cancellers: [AnyCanceller] = []

    func addCancellable<Canceller: Cancellable>(_ canceller: Canceller?) {
        guard let canceller = canceller else { return }
        cancellers.append(AnyCanceller(canceller))
    }

    func cancel() {
        for canceller in cancellers {
            canceller.cancel()
        }
    }
}
