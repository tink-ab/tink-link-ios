/// Message for a transfer, composed of a source and destination message.
public struct TransferMessage {
    /// Optional, The transfer description on the source account for the transfer.
    public var sourceMessage: String?

    /// The message to the recipient. If the payment recipient requires a structured (specially formatted) message, it should be set in this field.
    public var destinationMessage: String

    /// Creates a transfer message.
    ///
    /// - Parameters:
    ///   - sourceMessage: Optional, The transfer description on the source account for the transfer.
    ///   - destinationMessage: The message to the recipient. If the payment recipient requires a structured (specially formatted) message, it should be set in this field.
    public init(sourceMessage: String? = nil, destinationMessage: String) {
        self.sourceMessage = sourceMessage
        self.destinationMessage = destinationMessage
    }
}
