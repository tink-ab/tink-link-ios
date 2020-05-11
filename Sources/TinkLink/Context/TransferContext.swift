import Foundation

public final class TransferContext {
    private let tink: Tink
    private let service: RESTTransferService

    public convenience init(tink: Tink = .shared) {
        let service = RESTTransferService(client: tink.client)
        self.init(tink: tink, transferService: service)
    }

    init(tink: Tink, transferService: RESTTransferService) {
        self.tink = tink
        self.service = transferService
    }
}
