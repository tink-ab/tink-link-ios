import Foundation

public struct ClientDescription {
    let iconURL: URL?
    public let name: String
    let url: URL?
    let isEmbeddedAllowed: Bool
    let scopes: [ScopeDescription]
    let isVerified: Bool
    public let isAggregator: Bool
}
