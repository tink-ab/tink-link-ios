import Foundation

/// Description of a client using TinkLink.
public struct ClientDescription {
    let iconURL: URL?
    /// The name of the client.
    public let name: String
    let url: URL?
    let isEmbeddedAllowed: Bool
    let scopes: [ScopeDescription]
    /// Whether the client is verified.
    public let isVerified: Bool
    /// Whether the client is the aggregator.
    public let isAggregator: Bool
}
