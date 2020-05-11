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

    public func initiateTransfer(
        amount: ExactNumber,
        currencyCode: CurrencyCode,
        credentials: Credentials,
        sourceURI: Transfer.TransferEntityURI,
        destinationURI: Transfer.TransferEntityURI,
        message: String,
        completion: @escaping (Result<SignableOperation, Error>) -> Void
    ) -> RetryCancellable? {
        let transfer = Transfer(
            amount: amount,
            id: nil,
            credentialsID: credentials.id,
            currency: currencyCode,
            sourceMessage: message,
            destinationMessage: message,
            dueDate: nil,
            messageType: .freeText,
            destinationUri: destinationURI,
            sourceUri: sourceURI
        )

        return service.transfer(transfer: transfer, completion: completion)
    }

    public func transfer(id: Transfer.ID, completion: @escaping (Result<SignableOperation, Error>) -> Void) -> RetryCancellable? {
        return service.transferStatus(transferID: id, completion: completion)
    }
}
