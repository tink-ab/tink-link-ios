extension InitiateTransferTask {
    /// Message for a transfer, composed of a source and destination message.
    public struct Message {
        /// Optional, The transfer description on the source account for the transfer.
        public var source: String?

        /// The message to the recipient. If the payment recipient requires a structured (specially formatted) message, it should be set in this field.
        public var destination: String

        /// Creates a transfer message.
        ///
        /// - Parameters:
        ///   - source: Optional, The transfer description on the source account for the transfer.
        ///   - destination: The message to the recipient. If the payment recipient requires a structured (specially formatted) message, it should be set in this field.
        public init(source: String? = nil, destination: String) {
            self.source = source
            self.destination = destination
        }
    }
}
