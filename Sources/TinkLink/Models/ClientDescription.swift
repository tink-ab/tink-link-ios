import Foundation

struct ClientDescription {
    let iconURL: URL?
    let name: String
    let url: URL?
    let isEmbeddedAllowed: Bool
    let scopes: [ScopeDescription]
    let isVerified: Bool
    let isAggregator: Bool
}
