import Foundation

struct ClientDescription {
    let iconURL: URL?
    let name: String
    let url: URL?
    let embeddedAllowed: Bool
    let scopes: [ScopeDescription]
    let verified: Bool
    let aggregator: Bool
}
