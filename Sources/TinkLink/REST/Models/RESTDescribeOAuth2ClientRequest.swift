import Foundation

struct RESTDescribeOAuth2ClientRequest: Codable {
    let clientId: String
    let redirectUri: String
    let scope: String
}

struct RESTDescribeOAuth2ClientResponse: Codable {
    struct RESTScopeDescription: Codable {
        let title: String
        let description: String
    }

    let clientName: String
    let clientUrl: String
    let clientIconUrl: String
    var embeddedAllowed: Bool
    var scopesDescriptionsList: [RESTScopeDescription]
    var verified: Bool
    var aggregator: Bool
}
