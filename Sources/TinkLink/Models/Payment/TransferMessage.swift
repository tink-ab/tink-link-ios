public struct TransferMessage {
    public var sourceMessage: String?
    public var destinationMessage: String

    public init(sourceMessage: String? = nil, destinationMessage: String) {
        self.sourceMessage = sourceMessage
        self.destinationMessage = destinationMessage
    }
}
